# Cloudflare Tunnel for Home Assistant

![Project Stage][project-stage-shield]
![Maintenance][maintenance-shield]
[![License][license-shield]][license]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

## About

Cloudflare Argo Tunnel uses a tunnel and therefore bypasses any need for a NAT'd public IP (LTE connections) or opening firewall ports etc.

## How to use it

1. Update trusted proxies<br />

- Open /config/configuration.yaml using the file editor of your choice
- Add the following code **as is**:

```
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.0.0.200      # Add the IP address of the proxy server
    - 172.30.33.0/24  # You may also provide the subnet mask (This is the IPv4 IP range of hassio network)
```

_For more details:_

- https://www.home-assistant.io/integrations/http/#reverse-proxies

2. Add new repository ( https://github.com/w35l3y/hassio-addons )<br />

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fw35l3y%2Fhassio-addons)

- Click Supervisor > Add-ons Store<br />
- Click on the 3-dots button at the top right side and then Repositories<br />
- Copy and paste https://github.com/w35l3y/hassio-addons and then press Add<br />

3. Install add-on ( Cloudflare Tunnel )<br />

[![Open your Home Assistant instance and show the dashboard of a Supervisor add-on.](https://my.home-assistant.io/badges/supervisor_addon.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?addon=c50d1fa4_cloudflare_tunnel&repository_url=https%3A%2F%2Fgithub.com%2Fw35l3y%2Fhassio-addons)

- Press "Install"
- Open Configuration tab and add the following code:

| If you have your own domain | If you don't have your own domain |
| --- | --- |
| Your domain must be managed by [Cloudflare](https://dash.cloudflare.com/)<br />This way, you can have as many services as you want at once.<br />The last one is "catch-all", so it doesn't have specific hostname. You may also use wildcard character in hostname.<br /><br />Pay attention that the property `url` is **exclusive** to those who **don't have** own domain.<br />If you keep it, add-on will understand you don't have your own domain and ignore everything else.<br /><br />_Example with only Home Assistant_<pre>log_level: info<br />originRequest: {}<br />warp-routing: {}<br />ingress:<br />  - service: http://homeassistant:8123<br />    hostname: home.mydomain.com<br />  - service: http_status:404<br /></pre>_Example with many services at once_<br /><pre>log_level: info<br />originRequest: {}<br />warp-routing: {}<br />ingress:<br />  - service: http://homeassistant:8123<br />    hostname: home.mydomain.com<br />  - service: http://homeassistant:1880<br />    hostname: nodered.mydomain.com<br />  - service: mqtt://homeassistant:1883<br />    hostname: broker.mydomain.com<br />  - service: tcp://homeassistant:3306<br />    hostname: sql.mydomain.com<br />  - service: http_status:404<br /></pre>If you need to externalize more services, just add a new service and hostname for each of them.<br />**These are only examples... make sure to have some kind of authentication on each externalized service.**<br />Otherwise, it will be open to anyone in the world.<br /><br /><br />4. Start the addon and go to tab Log<br />   - The authorization page should show up in the Log<br />     ![Screenshot of the Log containing the login URL][log-login-url]<br />Ps.: Make sure to be logged in first. Otherwise, you will need to enter that page again because the login page doesn't redirect you back to the right page.<br /><br />5. Authorize<br />   - Copy and paste the authorization link in the browser<br />   - Click `mydomain.com`<br />   - Confirm the authorization<br />![Screenshot of the authorization page][cloudflare-authorization]<br />![Screenshot of the authorization popup][cloudflare-authorize] | This way, `a-very-long-random-subdomain-name.trycloudflare.com` will be created after you complete the instructions and it will be different on every boot.<br /><br />It is only recommended for testing purpose.<br />Consider getting your own domain for free at [Freenom](https://www.freenom.com).<br /><br /><pre>log_level: info<br />originRequest: {}<br />warp-routing: {}<br />ingress: []<br />url: http://homeassistant:8123<br /></pre><br />4. Start the addon and go to tab Log<br />   - The page should show up in the Log<br />![Screenshot of the Log containing the quick tunnel][log-quick-tunnel]<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /> |

**Don't mix things! Or you have your own domain or you don't have.**<br />

_For more details:_

- https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/trycloudflare
- https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/config
- https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/ingress#matching-traffic

## Common errors

- _Watchdog missing application response from c50d1fa4_cloudflare_tunnel_<br />
  _Keywords:_ restarting, disconnecting, watchdog, metrics<br />
  Change metrics to `0.0.0.0:41705` in the config.<br />
  For details, check https://github.com/w35l3y/hassio-addons/issues/22#issuecomment-1491623708

- _Tunnel credentials file '/data/tunnel.json' doesn't exist or is not a file_<br />
  _Keywords:_ conflict<br />
  Change the current tunnel name or reinstall the add-on.<br />

- _400: Bad Request_<br />
  _Keywords:_ proxy<br />
  Update `trusted_proxies` with the IP or range that is shown in the Home Assistant Logs (Sidebar `Configuration > Settings > Logs` and/or `Configuration > Add-ons, Backups & Supervisor > System > Log provider`).<br />
  For details on how to find the logs, check https://github.com/w35l3y/hassio-addons/issues/14#issuecomment-1115514830

- _Unable to reach the origin service. The service may be down or it may not be responding to traffic from cloudflared: **dial tcp: lookup xxx on xxx: server misbehaving**_<br />
  _Keywords:_ wrong service<br />
  Update `url` or `service` with the correct local IP and port of the service in the addon configuration (Add-on Cloudflare Tunnel > Configuration).<br />

- _Unable to reach the origin service. The service may be down or it may not be responding to traffic from cloudflared: **x509: cannot validate certificate for x.x.x.x because it doesn't contain any IP SANs**_<br />
  _Keywords:_ certificate<br />
  Update your internal SSL certificate because it is malformed/incomplete.<br />


## References

- <a href="https://iconscout.com/icons/cloudflare" target="_blank">
    Cloudflare Icon
  </a> on <a href="https://iconscout.com">Iconscout</a>
  <br />

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[commits]: https://github.com/w35l3y/hassio-addons/commits/main
[contributors]: https://github.com/w35l3y/hassio-addons/graphs/contributors
[gitlabci]: https://github.com/w35l3y/hassio-addons/cloudflare_tunnel/pipelines
[home-assistant]: https://home-assistant.io
[issue]: https://github.com/w35l3y/hassio-addons/issues
[license-shield]: https://img.shields.io/github/license/hassio-addons/addon-vscode.svg
[license]: https://github.com/w35l3y/hassio-addons/LICENSE.md
[maintenance-shield]: https://img.shields.io/maintenance/yes/2024.svg
[project-stage-shield]: https://img.shields.io/badge/Project%20Stage-Development-yellowgreen.svg
[releases]: https://github.com/w35l3y/hassio-addons/cloudflare_tunnel/releases
[semver]: http://semver.org/spec/v2.0.0.htm
[log-login-url]: https://github.com/w35l3y/hassio-addons/raw/main/cloudflare_tunnel/resources/img/log-login-url.jpg
[log-tunnel-created]: https://github.com/w35l3y/hassio-addons/raw/main/cloudflare_tunnel/resources/img/log-tunnel-created.jpg
[log-quick-tunnel]: https://github.com/w35l3y/hassio-addons/raw/main/cloudflare_tunnel/resources/img/log-quick-tunnel.png
[cloudflare-cname]: https://github.com/w35l3y/hassio-addons/raw/main/cloudflare_tunnel/resources/img/cloudflare-cname.jpg
[cloudflare-authorization]: https://github.com/w35l3y/hassio-addons/raw/main/cloudflare_tunnel/resources/img/cloudflare-authorization.png
[cloudflare-authorize]: https://github.com/w35l3y/hassio-addons/raw/main/cloudflare_tunnel/resources/img/cloudflare-authorize.png
