#!/usr/bin/with-contenv bashio

set -eE

if bashio::config.is_empty 'ingress[0].hostname'; then
  rm -f /data/cert.pem
  bashio::exit.nok "Hostname not defined"
fi

mkdir -p $HOME/.cloudflared
cp -r /data/. $HOME/.cloudflared

ls -R $HOME/.cloudflared

yq eval -P /data/options.json > /data/options.yml

cloudflared tunnel ingress validate --config /data/options.yml

cloudflared update

if ! bashio::fs.file_exists "$HOME/.cloudflared/cert.pem"; then
  cloudflared tunnel login

  cloudflared tunnel list
  TUNNEL=$(bashio::config 'tunnel')
  cloudflared tunnel delete -f "$TUNNEL"
  rm -rf $HOME/.cloudflared/*.json
  cloudflared tunnel create "$TUNNEL"

  cp -r $HOME/.cloudflared/. /data/
fi