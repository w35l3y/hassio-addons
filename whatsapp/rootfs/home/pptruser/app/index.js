const FALSY_VALUES = ['false', 'no', '0', 'null', 'undefined']
const convert = {
  'string': v => v || "",
  'number': v => v || "",
  'bool': v => v && !FALSY_VALUES.includes(v.toLowerCase().trim()) || false
}

let error = false
const constants = [
  { name: 'OPTS_HA_CHAT_IDS_FILTER', type: 'string', defaultValue: 'GROUP' },
  { name: 'OPTS_HA_DEFAULT_TO', type: 'string' },
  { name: 'OPTS_HA_DEFAULT_IDD', type: 'number' },
  { name: 'OPTS_HA_DEFAULT_DDD', type: 'number' },
  { name: 'OPTS_HA_NEW_SESSION', type: 'bool', defaultValue: 'false' },
  { name: 'OPTS_HA_RETRY_QUEUE', type: 'bool', defaultValue: 'true' },
  { name: 'OPTS_HA_DEBUG', type: 'bool', defaultValue: 'false' }
].reduce((acc, { name, type, defaultValue, required }) => {
  let value = convert[type](process.env[name] || defaultValue || '')

  if (required && !value) {
    error = true
    console.log(name, 'Required')
  }

  return {
    ...acc,
    [name]: value
  }
}, {})

if (error) {
  throw new Error('Some fields are required')
}

/////////////////////////// WHATSAPP

const qrcode = require('qrcode')
const axios = require('axios')
const fs = require('fs')
const { Client } = require('whatsapp-web.js')
const SESSION_FILE_PATH_R = '/data/session.json'
const SESSION_FILE_PATH_W = __dirname + '/session.json'

let queue = []
let sessionData = null
// https://github.com/home-assistant/supervisor/issues/2158
// https://developers.home-assistant.io/docs/api/supervisor/endpoints#addons
// https://github.com/just-containers/s6-overlay#fixing-ownership-and-permissions
if(!constants.OPTS_HA_NEW_SESSION && fs.existsSync(SESSION_FILE_PATH_R)) {
  sessionData = require(SESSION_FILE_PATH_R)
}

console.log(new Date(), 'session', sessionData?'EXISTING':'NEW')

const client = new Client({
  puppeteer: {
    authTimeout: 0, // https://github.com/pedroslopez/whatsapp-web.js/issues/935#issuecomment-952867521
    qrTimeoutMs: 0,
    headless: true,
    dumpio: constants.OPTS_HA_DEBUG,
    args: [
      '--disable-software-rasterizer',
      '--disable-gpu',
      '--single-process',
//      '--disable-setuid-sandbox',
//      '--no-sandbox',
//      '--no-zygote',
      '--ignore-gpu-blocklist',
      '--disable-dev-shm-usage'
    ]
  },
  session: sessionData
})

function request ({ url, headers, ...o }) {
  return axios({
    method: 'POST',
    url: new URL(url, 'http://supervisor/core/').href,
    ...o,
    headers: {
      authorization: 'Bearer ' + process.env.SUPERVISOR_TOKEN,
      ['content-type']: 'application/json',
      ...headers
    },
  })
}

client.on('qr', qr => {
  console.log(new Date(), 'qr')

  qrcode.toDataURL(qr, (err, url) => {
    request({
      url: 'api/services/persistent_notification/create',
      data: {
        notification_id: 'whatsapp_qrcode',
        title: 'WhatsApp - Link your device',
        message: '<img src="' + url + '" />'
      }
    })
  })
})

client.on('auth_failure', message => {
  console.log(new Date(), 'auth_failure', message)
})

client.on('authenticated', session => {
  console.log(new Date(), 'authenticated')

  sessionData = session
  fs.writeFile(SESSION_FILE_PATH_W, JSON.stringify(session), (err) => {
    if (err) {
      console.error(err)
    }
  })
})

async function send_queue() {
  if (queue.length) {
    return client.sendMessage(queue[0].to, queue[0].body).then(() => {
      queue.shift()
      setTimeout(send_queue, 1000)
      return 0
    }).catch(err => {
      console.log(new Date(), "send_queue", "error", err)
      return 1
    })
  }
  return 0
}

client.on('ready', () => {
  console.log(new Date(), 'ready')

  send_queue()
})

client.on('change_state', state => {
  console.log(new Date(), 'change_state', state)
})

client.on('disconnected', reason => {
  console.log(new Date(), 'disconnected', reason)
})

//client.on('message', message => {
//	if (message.body === '!ping') {
//    console.log(message)
//		client.sendMessage(message.from, 'pong')
//	}
//})

//client.on('message_ack', (message, ack) => {
/*
    == ACK VALUES ==
    ACK_ERROR: -1
    ACK_PENDING: 0
    ACK_SERVER: 1
    ACK_DEVICE: 2
    ACK_READ: 3
    ACK_PLAYED: 4
*/
//  console.log(new Date(), 'message_ack', message, ack, message.fromMe)
//})

console.log(new Date(), 'initialize')
client.initialize()

//////////////////////// SERVER

function get_chat_ids ({ body: { list = constants.OPTS_HA_CHAT_IDS_FILTER } }, res) {
  res.status(202).end()
  console.log("chat_ids", { list })

  client.getChats().then(items => {
    request({
      url: 'api/services/persistent_notification/create',
      data: {
        notification_id: 'whatsapp_chatIds',
        title: 'WhatsApp - Chat IDs',
        message: "<pre>" + items
          .filter(({ isGroup, isReadOnly }) => (list.toUpperCase() !== 'GROUP' || isGroup) && !isReadOnly)
          .sort((a, b) => -(a.isGroup > b.isGroup) || +(a.isGroup !== b.isGroup) || -(a.name < b.name) || +(a.name !== b.name))
          .map(({ id, name }) => ([id._serialized, name].join("\t"))).join("<br />") + "</pre>"
      }
    })
  }, err => {
    console.log(new Date(), "error", err)
    console.log(new Date(), 'reconnecting')
    client.initialize()
  })
}

function post_message ({ body: { to, body } }, res) {
  if (!body) {
    res.status(400).send({ messages: [ { type: "required.parameter", parameters: { name: "body" } } ] })
    return
  }
  res.status(202).end()

  if (!to) {
    to = constants.OPTS_HA_DEFAULT_TO
  }
  if (/^(\d{12,13})(?:@c\.us)?$/.test(to)) {
    to = RegExp.$1 + "@c.us"
  } else if (/^(\d{10,11})(?:@c\.us)?$/.test(to)) {
    to = constants.OPTS_HA_DEFAULT_IDD + RegExp.$1 + "@c.us"
  } else if (/^(\d{8,9})(?:@c\.us)?$/.test(to)) {
    to = constants.OPTS_HA_DEFAULT_IDD + "" + constants.OPTS_HA_DEFAULT_DDD + RegExp.$1 + "@c.us"
  } else if (/^(\d{12,13}-\d{10})(?:@g\.us)?$/.test(to)) {
    to = RegExp.$1 + "@g.us"
  }

  console.log("message", { to, body })
  client.sendMessage(to, body).catch(err => {
    console.log(new Date(), "error", err)
    if (!constants.OPTS_HA_RETRY_QUEUE) {
      console.log(new Date(), 'no queue')
    } else if (-1 === queue.findIndex(item => item.to === to && item.body === body)) {
      queue.push({ to, body })
      console.log(new Date(), 'reconnecting')
      client.initialize()
    }
  })
}

const express = require('express')

const app = express()

//app.use(['/ingress', '/ingress/*'], (req, res, next) => { // for `ingress` only
//  if (req.ip !== '::ffff:172.30.32.2') {
//    res.status(403).send({ messages: [ { type: "invalid.source", parameters: { name: "ip", value: req.ip } } ] })
//    return
//  }
//  next()
//}, express.static(__dirname + '/public'))

app.use(express.json(), (error, req, res, next) => {
  res.status(400).send({ messages: [ error ] })
})

app.post('/local/stdin', (req, res, next) => {  // for `hassio.addon_stdin` only
  if (req.ip !== '::ffff:127.0.0.1') {
    res.status(403).send({ messages: [ { type: "invalid.source", parameters: { name: "ip", value: req.ip } } ] })
    return
  }
  next()
}, ({ body: { type, value: body = {} } }, res) => {
  if (!type) {
    res.status(400).send({ messages: [ { type: "required.parameter", parameters: { name: "type" } } ] })
    return
  }

  switch (type) {
    case 'chat_ids':
    case 'chat-ids':
    case 'chatIds':
    case 'chat_id':
    case 'chat-id':
    case 'chatId':
      return get_chat_ids({ body }, res)
    case 'message':
      return post_message({ body }, res)
    default:
      res.status(400).send({ messages: [ { type: "unexpected.type", parameters: { type } } ] })
  }
})

//app.get('/api/chat_ids', get_chat_ids)
//app.post('/api/message', post_message)

app.listen(process.env.PORT, () => {
  console.log(new Date(), "listen", process.env.PORT)
})
