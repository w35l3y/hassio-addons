#!/usr/bin/with-contenv bashio

# quick tunnel
if bashio::config.has_value 'url'; then
  bashio::exit.ok
fi

CREDFILE=$(bashio::config "\"credentials-file\"" "/data/tunnel.json")
OLD_ORIGINCERT="$HOME/.cloudflared/cert.pem"
NEW_ORIGINCERT=$(bashio::config "origincert" "/data/cert.pem")

# validations
if bashio::config.is_empty "ingress[0].hostname"; then
  rm -f "$CREDFILE"
  bashio::exit.nok "Hostname not defined"
fi

if bashio::config.is_empty "tunnel"; then
  rm -f "$CREDFILE"
  bashio::exit.nok "Tunnel not defined"
fi

cloudflared tunnel --config=/data/options.json ingress validate || bashio::exit.nok "Config file is invalid"

NEW_TUNNEL=$(bashio::config "tunnel")
OLD_TUNNEL=$(bashio::cache.get "addons.self.info.TunnelName" || echo "$NEW_TUNNEL")

echo "Checking certificate..."
# certificate not found or tunnel changed name
if ! bashio::fs.file_exists "$NEW_ORIGINCERT" || [[ "$OLD_TUNNEL" != "$NEW_TUNNEL" ]] || ! bashio::fs.file_exists "$CREDFILE"; then
  echo "Logging..."
  cloudflared tunnel --config=/data/options.json login

  if [[ "$OLD_ORIGINCERT" != "$NEW_ORIGINCERT" && "$NEW_ORIGINCERT" == /data/* ]]; then
    echo "Moving certificate..."
    mv -fv "$OLD_ORIGINCERT" "$NEW_ORIGINCERT"
  fi

  echo "Listing tunnels..."
  cloudflared tunnel --config=/data/options.json list

  echo "Deleting tunnels..."
  cloudflared tunnel --config=/data/options.json delete -f "$OLD_TUNNEL" || true
  cloudflared tunnel --config=/data/options.json delete -f "$NEW_TUNNEL" || true

  echo "Removing credentials file..."
  rm -f "$CREDFILE"

  echo "Creating tunnel..."
  cloudflared tunnel --config=/data/options.json --credentials-file="$CREDFILE" create "$NEW_TUNNEL"

  bashio::cache.set "addons.self.info.TunnelName" "$NEW_TUNNEL"
fi

echo "Adding routes..."
for index in $(bashio::config "ingress|keys"); do
  HOSTNAME=$(bashio::config "ingress[${index}].hostname")

  if [[ -n "$HOSTNAME" && "$HOSTNAME" != "null" ]]; then
    cloudflared tunnel --config=/data/options.json route dns -f "$NEW_TUNNEL" "$HOSTNAME" || bashio::exit.nok "Failed to create DNS route: $HOSTNAME"
  fi
done
