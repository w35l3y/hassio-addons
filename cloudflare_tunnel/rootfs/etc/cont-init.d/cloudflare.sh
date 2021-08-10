#!/usr/bin/with-contenv bashio

set -eE

if bashio::config.is_empty 'ingress[0].hostname'; then
  bashio::exit.nok "Hostname not defined"
fi

mkdir -p $HOME/.cloudflared
cp -r /data/. $HOME/.cloudflared
ls -R $HOME/.cloudflared

if ! bashio::fs.file_exists "$HOME/.cloudflared/cert.pem"; then
  cloudflared tunnel login
fi

TUNNEL=$(bashio::config 'tunnel')
cloudflared tunnel delete -f "$TUNNEL"
rm -rf $HOME/.cloudflared/*.json
cloudflared tunnel create "$TUNNEL"

cp -r $HOME/.cloudflared/. /data/