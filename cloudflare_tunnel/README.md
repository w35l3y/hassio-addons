# Cloudflare Tunnel for Home Assistant

![Project Stage][project-stage-shield]
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

- Open /config/configuration.yaml using the file editor of your choice<br />
- Add the following code:<br />

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

- Click Supervisor > Add-ons Store<br />
- Click on the 3-dots button at the top right side and then Repositories<br />
- Copy and paste https://github.com/w35l3y/hassio-addons and then press Add<br />

3. Install add-on ( Cloudflare Tunnel )<br />

- Press Install<br />
- Open Configuration and add the following code:<br />

If you **don't have** your own domain<br />
Note: This way, `a-very-long-random-subdomain-name.trycloudflare.com` will be created and it will be different on every boot.<br />

```
no-autoupdate: true
ingress: []
url: http://local_ip:8123
```

If you **have** your own domain<br />
Note: This way, you can have as many services as you want at once. Just add a new hostname and service. The last one is "catch-all", so it doesn't have specific hostname. You may also use wildcard character in hostname.<br />

```
no-autoupdate: true
ingress:
  - hostname: example.mydomain.com
    service: http://local_ip:8123
  - service: http_status:404 # Leave it as is
tunnel: hassio # May be anything you want. It identifies the tunnel and doesn't have anything to do with hostname
```

_For more details:_

- https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/trycloudflare
- https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/config
- https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/ingress#matching-traffic

4. Start the addon and go to tab Log<br />
   - If you **don't have** your own domain, that should be it!<br />
     - The page should show up in the Log<br />
   - If you **have** your own domain, then follow the remaining steps.<br />
     - The authetication page should show up in the Log<br />
       ![Screenshot of the Log containing the login URL][log-login-url]
5. Authenticate _(Beyond steps are for custom domains only)_<br />
   - Copy and paste the authentication link in the browser<br />
   - Click `mydomain.com`<br />
   - Confirm the authentication<br />
6. Get Tunnel ID<br />
   - Return to tab Log<br />
   - Copy the Tunnel ID
     ![Screenshot of the Log containing the Tunnel ID][log-tunnel-created]
7. Add CNAME<br />
   - Go to https://dash.cloudflare.com/?zone=dns<br />
   - Add CNAME `example` alias to `<tunnelID>.cfargotunnel.com` with proxy enabled
     - Change `<tunnelID>` to the Tunnel ID, for example, `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.cfargotunnel.com`
       ![Screenshot of the Cloudflare Dash][cloudflare-cname]

## Common errors

- _400: Bad Request_<br />
  Update `trusted_proxies` with the IP or range that is shown in the HA Logs (Sidebar Configurations > Logs).

- _Unable to reach the origin service. The service may be down or it may not be responding to traffic from cloudflared: dial tcp: lookup xxx on xxx: server misbehaving_<br />
  Update `url` or `service` with the correct local IP and port of the service in the addon configuration (Add-on Cloudflare Tunnel > Configuration).<br />
  I wasn't able to make it work with DNS names, for example, `http://homeassistant.local:8123`.<br />
  So, let me know if you did it successfully.

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
[maintenance-shield]: https://img.shields.io/maintenance/yes/2021.svg
[project-stage-shield]: https://img.shields.io/badge/Project%20Stage-Development-yellowgreen.svg
[releases]: https://github.com/w35l3y/hassio-addons/cloudflare_tunnel/releases
[semver]: http://semver.org/spec/v2.0.0.htm
[log-login-url]: https://github.com/w35l3y/hassio-addons/raw/main/cloudflare_tunnel/resources/img/log-login-url.jpg
[log-tunnel-created]: https://github.com/w35l3y/hassio-addons/raw/main/cloudflare_tunnel/resources/img/log-tunnel-created.jpg
[cloudflare-cname]: https://github.com/w35l3y/hassio-addons/raw/main/cloudflare_tunnel/resources/img/cloudflare-cname.jpg
