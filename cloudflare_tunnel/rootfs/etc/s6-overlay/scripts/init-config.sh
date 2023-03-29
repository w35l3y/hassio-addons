#!/command/with-contenv bashio
# shellcheck disable=SC2207

bashio::log.trace "<init-config>"

bashio::log.blue "-----------------------------------------------------------"

# quick tunnel
if bashio::config.has_value 'url'; then
  bashio::log.blue " Quick tunnel: $(bashio::config 'url')"
  bashio::log.blue "-----------------------------------------------------------"
  if ! bashio::config.is_empty "ingress"; then
    bashio::log.info "If you intend to use your own domain, remove 'url'"
    bashio::log.blue "-----------------------------------------------------------"
  fi
  bashio::exit.ok
fi

CREDFILE=$(bashio::config "\"credentials-file\"" "/data/tunnel.json")
OLD_ORIGINCERT="$HOME/.cloudflared/cert.pem"
NEW_ORIGINCERT=$(bashio::config "origincert" "/data/cert.pem")
DEBUG=$(bashio::config "loglevel" "info")

# validations
if bashio::config.is_empty "ingress[0].hostname"; then
  rm -f "$CREDFILE"
  bashio::exit.nok "'ingress[].hostname' is empty, please enter a valid String"
fi

if bashio::config.is_empty "tunnel"; then
  rm -f "$CREDFILE"
  bashio::exit.nok "'tunnel' is empty, please enter a valid String"
fi

cloudflared tunnel --config=/data/options.json ingress validate || bashio::exit.nok "Config file is invalid"

NEW_TUNNEL=$(bashio::config "tunnel")
OLD_TUNNEL=$(bashio::cache.get "addons.self.info.TunnelName" || echo "$NEW_TUNNEL")

bashio::log.blue " Checking certificate..."
# certificate not found or tunnel changed name
if ! bashio::fs.file_exists "$NEW_ORIGINCERT" || [[ "$OLD_TUNNEL" != "$NEW_TUNNEL" ]] || ! bashio::fs.file_exists "$CREDFILE"; then
  bashio::log.debug "$NEW_ORIGINCERT exists : $(bashio::fs.file_exists '$NEW_ORIGINCERT')"
  bashio::log.debug "$CREDFILE exists : $(bashio::fs.file_exists '$CREDFILE')"
  bashio::log.debug "Old tunnel name : $OLD_TUNNEL"
  bashio::log.debug "New tunnel name : $NEW_TUNNEL"

  bashio::log.blue " Logging..."
  cloudflared tunnel --config=/data/options.json login

  if [[ "$OLD_ORIGINCERT" != "$NEW_ORIGINCERT" && "$NEW_ORIGINCERT" == /data/* ]]; then
    bashio::log.blue " Moving certificate..."
    mv -fv "$OLD_ORIGINCERT" "$NEW_ORIGINCERT"
  else
    bashio::log.debug "Old origin cert : $OLD_ORIGINCERT"
    bashio::log.debug "New origin cert : $NEW_ORIGINCERT"
    bashio::log.info "Certificate not moved"
  fi

  bashio::log.blue " Listing tunnels..."
  cloudflared tunnel --config=/data/options.json list

  bashio::log.blue " Deleting tunnels..."
  cloudflared tunnel --config=/data/options.json delete -f "$OLD_TUNNEL" || true
  cloudflared tunnel --config=/data/options.json delete -f "$NEW_TUNNEL" || true

  bashio::log.blue " Removing credentials file..."
  rm -f "$CREDFILE"

  bashio::log.blue " Creating tunnel..."
  cloudflared tunnel --config=/data/options.json --credentials-file="$CREDFILE" create "$NEW_TUNNEL"

  bashio::cache.set "addons.self.info.TunnelName" "$NEW_TUNNEL"
fi

bashio::log.blue " Adding routes..."
for index in $(bashio::config "ingress|keys"); do
  HOSTNAME=$(bashio::config "ingress[${index}].hostname")

  if [[ -n "$HOSTNAME" && "$HOSTNAME" != "null" ]]; then
    cloudflared tunnel --config=/data/options.json route dns -f "$NEW_TUNNEL" "$HOSTNAME" || bashio::exit.nok "Failed to create DNS route: $HOSTNAME"
  fi
done

bashio::log.blue "-----------------------------------------------------------"

bashio::log.trace "</init-config>"
