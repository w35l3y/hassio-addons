# Alexa Proxy for Home Assistant

![Project Stage][project-stage-shield]
[![License][license-shield]][license]

## About

When we create a Custom Alexa Skill, we need to define an endpoint that may be `AWS Lambda ARN` or `HTTPS`<br />
This add-on helps to provide a way to use `HTTPS`<br />

![Example of Alexa Custom Skill Settings][alexa-custom-skill]

It just reads the `access_token` from the request body and redirects the request with it in the request header.<br />
This is needed simply because Amazon sends the token in the request body and Home Assistant only recognizes it in the request header.

This add-on is better used with add-on [Cloudflare Tunnel](https://my.home-assistant.io/redirect/supervisor_addon/?addon=c50d1fa4_cloudflare_tunnel&repository_url=https%3A%2F%2Fgithub.com%2Fw35l3y%2Fhassio-addons) or any other that does the same thing.

## How to use it

This will be explained as you were using the add-on [Cloudflare Tunnel](https://my.home-assistant.io/redirect/supervisor_addon/?addon=c50d1fa4_cloudflare_tunnel&repository_url=https%3A%2F%2Fgithub.com%2Fw35l3y%2Fhassio-addons).

1. Add new repository ( https://github.com/w35l3y/hassio-addons )<br />

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fw35l3y%2Fhassio-addons)

- Click Supervisor > Add-ons Store<br />
- Click on the 3-dots button at the top right side and then Repositories<br />
- Copy and paste https://github.com/w35l3y/hassio-addons and then press Add<br />

2. Install add-on ( Alexa Proxy )<br />

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=c50d1fa4_alexa_proxy&repository_url=https%3A%2F%2Fgithub.com%2Fw35l3y%2Fhassio-addons)

- Press "Install"

By default, it uses `http://homeassistant:8123` as the base URL to redirect and port `3015` to receive the requests.<br />
If you want to modify it, just go to `Configuration` tab and change it.<br />
Fill `OPTS_HA_TOKEN` _if only if_ you want to ignore the token received in the request body.<br />

3. Start the add-on<br />

- If you are good with default settings, that should be it for this add-on!

4. Open the add-on `Cloudflare Tunnel`<br />

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=c50d1fa4_cloudflare_tunnel&repository_url=https%3A%2F%2Fgithub.com%2Fw35l3y%2Fhassio-addons)

- If you don't have it installed, follow the steps on [how to use it](https://github.com/w35l3y/hassio-addons/tree/main/cloudflare_tunnel#how-to-use-it).
- If you use an alternative add-on, basically, you will need to find out by yourself how to add a new ingress explained below.

5. Add a new ingress<br />

- Go to the `Configuration` tab of `Cloudflare Tunnel` and add a new service just like so:

```yaml
ingress:
  - hostname: alexa-proxy.mydomain.com      # subdomain of your domain that will be used to receive requests from Alexa Custom Skill
    service: http://homeassistant:3015      # instance of HA and port that points to the `Alexa Proxy`
```


[commits]: https://github.com/w35l3y/hassio-addons/commits/main
[contributors]: https://github.com/w35l3y/hassio-addons/graphs/contributors
[gitlabci]: https://github.com/w35l3y/hassio-addons/alexa_proxy/pipelines
[home-assistant]: https://home-assistant.io
[issue]: https://github.com/w35l3y/hassio-addons/issues
[license-shield]: https://img.shields.io/github/license/hassio-addons/addon-vscode.svg
[license]: https://github.com/w35l3y/hassio-addons/LICENSE.md
[maintenance-shield]: https://img.shields.io/maintenance/yes/2022.svg
[project-stage-shield]: https://img.shields.io/badge/Project%20Stage-Development-yellowgreen.svg
[semver]: http://semver.org/spec/v2.0.0.htm
[alexa-custom-skill]: https://github.com/w35l3y/hassio-addons/raw/main/alexa_proxy/resources/img/alexa-custom-skill.png
