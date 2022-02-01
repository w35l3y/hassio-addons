#!/usr/bin/with-contenv bashio

while read -r input; do
  rsync /home/pptruser/app/session.json /data/session.json # workaround as pptruser can't write at /data
  curl --silent --output /dev/null --show-error -X POST -H "Content-Type: application/json" -d "$input" http://localhost:8099/local/stdin
done
