#!/usr/bin/with-contenv bashio

set -eE

yq eval -P /data/options.json > /data/options.yaml

if bashio::config.has_value 'url'; then
  exit 0
fi

if bashio::config.is_empty 'ingress[0].hostname'; then
  rm -f /data/cert.pem
  bashio::exit.nok "Hostname not defined"
fi

mkdir -p $HOME/.cloudflared
cp -r /data/. $HOME/.cloudflared

ls -R $HOME/.cloudflared

cloudflared tunnel --config /data/options.yaml ingress validate

cloudflared update

if ! bashio::fs.file_exists "$HOME/.cloudflared/cert.pem"; then
  cloudflared tunnel login

  cloudflared tunnel list
  TUNNEL=$(bashio::config 'tunnel')

  cloudflared tunnel delete -f "$TUNNEL" || true

  rm -rf $HOME/.cloudflared/*.json
  cloudflared tunnel create "$TUNNEL"

  rm -rf /data/*.json
  cp -r $HOME/.cloudflared/. /data/
fi
