# WhatsApp for Home Assistant

![Project Stage][project-stage-shield]
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
- Open Configuration and certify `OPTS_HA_BASE_URL` and `OPTS_HA_TOKEN` (Long-Lived Access Token) are filled correctly.

[![Open your Home Assistant instance and show your Home Assistant user's profile.](https://my.home-assistant.io/badges/profile.svg)](https://my.home-assistant.io/redirect/profile/)

It is recommended to create a specific `long-lived access token` to the add-on.

![Screenshot of the User Profile with Long-lived access token created][long-lived-access-token-created]

_For more details:_

- https://developers.home-assistant.io/docs/api/rest
- https://developers.home-assistant.io/docs/auth_api/#long-lived-access-token
- https://developers.home-assistant.io/docs/auth_api/#making-authenticated-requests

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
* `chatIds`: by default, retrieves the list of all your active groups in the log of the add-on in order to get the `chatId` of groups.
* `message`: sends a message from your account to someone else

Example 1:
```
service: hassio.addon_stdin
data:
  addon: c50d1fa4_whatsapp
  input:
    type: chatIds
```
It will list the chatIds in the Log tab.

Example 2:
```
service: hassio.addon_stdin
data:
  addon: c50d1fa4_whatsapp
  input:
    type: message
    value:
      to: nnnnnnnnnnnn  # chatId (*)
      body: your message goes here
```
(*) If you want to send a message to a group, then call "chatIds" to identity what is its `chatId`.<br />
contact `chatId` usually is composed of IDD + DDD + PHONE NUMBER (numbers only) followed by "@c.us"<br />
group `chatId` doesn't seem to follow a pattern except that ends with "@g.us"<br />

[![Open your Home Assistant instance and show your service developer tools.](https://my.home-assistant.io/badges/developer_services.svg)](https://my.home-assistant.io/redirect/developer_services/)

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
[maintenance-shield]: https://img.shields.io/maintenance/yes/2022.svg
[project-stage-shield]: https://img.shields.io/badge/Project%20Stage-Development-yellowgreen.svg
[semver]: http://semver.org/spec/v2.0.0.htm
[long-lived-access-token-created]: https://github.com/w35l3y/hassio-addons/raw/main/whatsapp/resources/img/long-lived-access-token-created.jpg
