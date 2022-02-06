#!/usr/bin/with-contenv bashio

# https://github.com/just-containers/s6-overlay/issues/243#issue-377179305
# Load custom environment variables
for var in $(bashio::config "env_vars|keys"); do
    name=$(bashio::config "env_vars[${var}].name")
    value=$(bashio::config "env_vars[${var}].value")
#    bashio::log.info "Setting ${name} to ${value}"
    printf "${value}" > /var/run/s6/container_environment/${name}
done

# https://stedolan.github.io/jq/manual/#tostring
json=$(bashio::config "tags|tostring")
printf "${json}" > /var/run/s6/container_environment/OPTS_HA_TAGS

node --version
which -a node
npm --version
which -a npm
chromium-browser --version
which -a chromium-browser
