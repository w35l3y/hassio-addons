const FALSY_VALUES = ['false', 'no', '0', 'null', 'undefined']
const convert = {
  'string': v => v || "",
  'number': v => v || "",
  'bool': v => v && !FALSY_VALUES.includes(v.toLowerCase().trim()) || false
}

const constants = [
  { name: 'OPTS_HA_BASE_URL', type: 'string' },
  { name: 'OPTS_HA_TOKEN', type: 'string' },
  { name: 'PORT', type: 'string' }
].reduce((acc, { name, type }) => ({
  ...acc,
  [name]: convert[type](process.env[name])
}), {})
console.log(constants)

const express = require('express')
const axios = require('axios')
const app = express()

const token_keys = [
  { "mode": "INTENT", "key": "session.user.accessToken" },
  { "mode": "INTENT", "key": "context.System.user.accessToken" },
  { "mode": "SMART_HOME", "key": "directive.endpoint.scope.token" },
  { "mode": "SMART_HOME", "key": "directive.payload.grantee.token" },
  { "mode": "SMART_HOME", "key": "directive.payload.scope.token" },
].map(({ mode, key }) => ({
  mode,
  key: key.split(".")
}))

const get_token = (ctx, defaultValue) => {
  for (const { mode, key } of token_keys) {
    let token = key.reduce((acc, value) => acc[value] || false, ctx)
    if (token) return { mode, token }
  }
  return { token: constants.OPTS_HA_TOKEN || defaultValue || "" }
}

const INTERNAL_URLS = {
  INTENT: "/api/alexa",
  SMART_HOME: "/api/alexa/smart_home"
}

app.use(express.json(), async ({ originalUrl, method, headers, params, body }, res) => {
  let { mode, token } = get_token(body, headers.authorization)
  if (!token) {
    return res.status(401).send({
      event: {
        payload: {
          type: 'INVALID_AUTHORIZATION_CREDENTIAL'
        }
      }
    })
  }

  let url = (new URL(INTERNAL_URLS[mode] || originalUrl, constants.OPTS_HA_BASE_URL)).href

  console.log(new Date(), method, url, body.request)

  const { status, data } = await axios({
    url,
    method,
    headers: {
      authorization: "Bearer " + token,
      ['content-type']: "application/json"
    },
    params,
    data: body
  })

  return res.status(status).send(data)
})

app.listen(constants.PORT, () => {
  console.log(new Date(), "listen", constants.PORT)
})
