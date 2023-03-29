#!/command/with-contenv bashio

bashio::log.trace "<init-log>"

loglevel=$(bashio::config "log_level" "info")
case $loglevel in
  "notset") loglevel="trace";;
#  "debug") loglevel="debug";;
#  "info") loglevel="info";;
#  "warn") loglevel="warn";;
  "warning") loglevel="warn";;
#  "error") loglevel="error";;
#  "fatal") loglevel="fatal";;
  "critital") loglevel="panic";;
esac

#bashio::log.blue " Log level mapped to '$loglevel'"
#printf "${loglevel}" > /var/run/s6/container_environment/TUNNEL_LOGLEVEL
# https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/local-management/arguments/#loglevel

bashio::log.trace "</init-log>"
