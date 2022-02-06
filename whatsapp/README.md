# WhatsApp for Home Assistant

![Project Stage][project-stage-shield]
![Maintenance][maintenance-shield]
[![License][license-shield]][license]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

## About

WhatsApp for Home Assistant uses [whatsapp-web.js](https://github.com/pedroslopez/whatsapp-web.js/) to access WhatsApp WEB in background.<br />That said, it won't work too well with another concurrent session open.

## How to use it

1. Add new repository ( https://github.com/w35l3y/hassio-addons )<br />

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fw35l3y%2Fhassio-addons%2F)

- Click Supervisor > Add-ons Store
- Click on the 3-dots button at the top right side and then Repositories
- Copy and paste https://github.com/w35l3y/hassio-addons and then press Add

2. Install add-on ( WhatsApp )<br />

- Press "Install"

3. Start the add-on and link a device

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=c50d1fa4_whatsapp)

- Open your WhatsApp mobile app to link a device
- Press "Start"
- Wait for the QR Code to show up in the Notification bar
- Point your WhatsApp to the QR Code

_For more details:_

- https://faq.whatsapp.com/web/download-and-installation/how-to-link-a-device

4. Call the service `hassio.addon_stdin`

Currently, these are the only acceptable types:
* `chatIds`: by default, prints in the Notification bar the list of all your active `chatId` groups
* `message`: sends a message from your account to someone else

#### Example 1
```
service: hassio.addon_stdin
data:
  addon: c50d1fa4_whatsapp
  input:
    type: chatIds
    value:
      list: ALL # GROUP by default
```
It will list the chatIds in the Notification bar.

_For more details:_

- https://docs.wwebjs.dev/Client.html#getChats

#### Example 2
```
service: hassio.addon_stdin
data:
  addon: c50d1fa4_whatsapp
  input:
    type: message
    value:
      to: nnnnnnnnnnnn  # receiver chatId (*)
      body: Your message goes here
```
(\*) If you want to send a message to a group, then call "chatIds" to identity what is its `chatId`.<br />
contact `chatId` usually is composed of IDD + DDD + PHONE NUMBER (numbers only) followed by "@c.us"<br />
If you have a brazilian phone number like: +55 (11) 988-888-888, then the `chatId` will be `551188888888@c.us` for old accounts and `5511988888888@c.us` for new accounts<br />
group `chatId` doesn't seem to follow a pattern except that ends with "@g.us"<br />
If you aren't sure about what `chatId` to inform, then call the [Example 1](#example-1) first.

<img src="https://github.com/w35l3y/hassio-addons/raw/main/whatsapp/resources/img/example-2-simple.jpg" title="Example of simple message" height="100" />

_For more details:_

- https://docs.wwebjs.dev/Client.html#sendMessage

#### Example 3
```
service: hassio.addon_stdin
data:
  addon: c50d1fa4_whatsapp
  input:
    type: message
    value:
      to: nnnnnnnnnnnn  # receiver chatId
      url: https://s.gravatar.com/avatar/81269f79d21e612f9f307d16b09ee82b?s=100
      options:
        unsafeMime: true
```
Sends a file based on the url

<img src="https://github.com/w35l3y/hassio-addons/raw/main/whatsapp/resources/img/example-3-url.jpg" title="Example of attachment" height="100" />

_For more details:_

- https://docs.wwebjs.dev/MessageMedia.html#.fromUrl

#### Example 4
```
service: hassio.addon_stdin
data:
  addon: c50d1fa4_whatsapp
  input:
    type: message
    value:
      to: nnnnnnnnnnnn  # receiver chatId
      filePath: ...
```
Sends a file based on the filePath

_For more details:_

- https://docs.wwebjs.dev/MessageMedia.html#.fromFilePath

#### Example 5
```
service: hassio.addon_stdin
data:
  addon: c50d1fa4_whatsapp
  input:
    type: message
    value:
      to: nnnnnnnnnnnn  # receiver chatId
      latitude: 51.477928
      longitude: -0.001545
```
Sends location

<img src="https://github.com/w35l3y/hassio-addons/raw/main/whatsapp/resources/img/example-5-location.jpg" title="Example of location" height="100" />

_For more details:_

- https://docs.wwebjs.dev/Location.html

#### Example 6
```
service: hassio.addon_stdin
data:
  addon: c50d1fa4_whatsapp
  input:
    type: message
    value:
      to: nnnnnnnnnnnn  # receiver chatId
      title: Title
      body: Content
      footer: Footer
      buttons:
        - body: Button A
        - body: Button B
```
Sends a message with 2 buttons (limit = 3 buttons)

<img src="https://github.com/w35l3y/hassio-addons/raw/main/whatsapp/resources/img/example-6-buttons.jpg" title="Example of buttons" height="100" />

_For more details:_

- https://docs.wwebjs.dev/Buttons.html

#### Example 7
```
service: hassio.addon_stdin
data:
  addon: c50d1fa4_whatsapp
  input:
    type: message
    value:
      to: nnnnnnnnnnnn  # receiver chatId
      title: Title
      body: Content
      footer: Footer (it is in the API, but doesn't show up)
      buttonText: Options
      sections:
        - title: Section A
          rows:
            - title: Option A.1
            - title: Option A.2
        - title: Section B
          rows:
            - title: Option B.1
            - title: Option B.2
```
Sends a message with a list of sections

<img src="https://github.com/w35l3y/hassio-addons/raw/main/whatsapp/resources/img/example-7-sections-closed.jpg" title="Example of sections closed" height="100" />
<img src="https://github.com/w35l3y/hassio-addons/raw/main/whatsapp/resources/img/example-7-sextions-opened.jpg" title="Example of sections opened" height="100" />

_For more details:_

- https://docs.wwebjs.dev/List.html

[![Open your Home Assistant instance and show your service developer tools.](https://my.home-assistant.io/badges/developer_services.svg)](https://my.home-assistant.io/redirect/developer_services/)

#### Example 8
```
- alias: "Receiving commands from WhatsApp to Alexa"
  trigger:
    platform: event
    event_type: whatsapp_message
    event_data:
      tags:
        - ALEXA_REQUEST
        - ALEXA_REQUEST_WHITELIST
    context:
      user_id: !secret supervisor_user_id
  action:
    - service: media_player.play_media
      data:
        entity_id: "media_player.my_echo_dot"
        media_content_type: custom
        media_content_id: '{{ trigger.event.data.body }}'
    - service: hassio.addon_stdin
      data:
        addon: c50d1fa4_whatsapp
        input:
          type: message
          value:
            to: ALEXA_RESPONSE
            body: 'Received command: {{ trigger.event.data.body }}'
            options:
              quotedMessageId: '{{ trigger.event.data.messageId }}'
```
Example of automation that is triggered by an event named `whatsapp_message` and sent to Alexa

_For more details:_

- https://docs.wwebjs.dev/global.html#MessageSendOptions

#### Example 9
```
- alias: "Receiving location request from WhatsApp"
  trigger:
    platform: event
    event_type: whatsapp_message
    event_data:
      tags:
        - LOCATION_REQUEST
        - LOCATION_REQUEST_WHITELIST
      body: "!location"
    context:
      user_id: !secret supervisor_user_id
  action:
    - service: hassio.addon_stdin
      data:
        addon: c50d1fa4_whatsapp
        input:
          type: message
          value:
            to: '{{ trigger.event.data.author }}'
            latitude: 51.477928
            longitude: -0.001545
            description: "Party Location"
```
Example of automation that is triggered by an event named `whatsapp_message` and sent back to WhatsApp

## Common errors

- _ERR! cb() never called!_<br />
  Try reinstalling the add-on again.

## Known limitations

- Add-on doesn't work simultaneously with WhatsApp Web.<br />
  If you have it already open and start the add-on, it will stop your WhatsApp Web.<br />
  If you have the add-on open and start WhatsApp Web, it will stop the add-on from working.
- Session will be stored after calling the service. In other words,<br />
  if you restart the add-on before calling it, then a new QR code will be requested.


[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[commits]: https://github.com/w35l3y/hassio-addons/commits/main
[contributors]: https://github.com/w35l3y/hassio-addons/graphs/contributors
[gitlabci]: https://github.com/w35l3y/hassio-addons/whatsapp/pipelines
[home-assistant]: https://home-assistant.io
[issue]: https://github.com/w35l3y/hassio-addons/issues
[license-shield]: https://img.shields.io/github/license/hassio-addons/addon-vscode.svg
[license]: https://github.com/w35l3y/hassio-addons/LICENSE.md
[maintenance-shield]: https://img.shields.io/maintenance/yes/2022
[project-stage-shield]: https://img.shields.io/badge/Project%20Stage-Development-yellowgreen.svg
[semver]: http://semver.org/spec/v2.0.0.htm
