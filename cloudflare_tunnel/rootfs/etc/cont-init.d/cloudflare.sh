#!/usr/bin/with-contenv bashio

# quick tunnel
if bashio::config.has_value 'url'; then
  bashio::exit.ok
fi

# validations
if bashio::config.is_empty "ingress[0].hostname"; then
  rm -f /data/cert.pem
  bashio::exit.nok "Hostname not defined"
fi

if bashio::config.is_empty "tunnel"; then
  rm -f /data/cert.pem
  bashio::exit.nok "Tunnel not defined"
fi

cloudflared tunnel --config=/data/options.json ingress validate || bashio::exit.nok "Config file is invalid"

#copy persistent files
CLOUDFLARE_PATH="$HOME/.cloudflared"
CREDFILE="$CLOUDFLARE_PATH/tunnel.json"

mkdir -p "$CLOUDFLARE_PATH"
cp -r /data/. "$CLOUDFLARE_PATH"

ls -R "$CLOUDFLARE_PATH"

NEW_TUNNEL=$(bashio::config "tunnel")
OLD_TUNNEL="$NEW_TUNNEL"
if bashio::fs.file_exists "$CREDFILE"; then
  OLD_TUNNEL=$(bashio::jq "$CREDFILE" ".TunnelName")
fi

# certificate not found or tunnel changed name
if ! bashio::fs.file_exists "$CLOUDFLARE_PATH/cert.pem" || [[ "$OLD_TUNNEL" != "$NEW_TUNNEL" ]]; then
  cloudflared tunnel login

  cloudflared tunnel list

  cloudflared tunnel delete -f "$OLD_TUNNEL" || true
  cloudflared tunnel delete -f "$NEW_TUNNEL" || true

  rm -f "$CREDFILE"

  cloudflared --credentials-file="$CREDFILE" tunnel create "$NEW_TUNNEL"

  cp -r $CLOUDFLARE_PATH/. /data/
fi

for index in $(bashio::config "ingress|keys"); do
  HOSTNAME=$(bashio::config "ingress[${index}].hostname")

  if [[ -n "$HOSTNAME" && "$HOSTNAME" != "null" ]]; then
    cloudflared tunnel route dns -f "$NEW_TUNNEL" "$HOSTNAME" || bashio::exit.nok "Failed to create DNS route: $HOSTNAME"
  fi
done
