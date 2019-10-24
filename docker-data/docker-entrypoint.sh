#!/bin/sh

set -ex

if [[ "$1" = 'redis-cluster' ]]; then
  if [[ -e /redis-data/7000/nodes.conf ]] && [[ x"${ENV}" = x"production" ]]; then
    exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
  else
    for port in `seq 7000 7005`; do
      mkdir -p /redis-conf/${port}
      mkdir -p /redis-data/${port}

      # remove nodes configuration if they exist in non-production mode
      if [[ -e /redis-data/${port}/nodes.conf ]]; then
        rm /redis-data/${port}/nodes.conf
      fi
    done

    # recreate redis configuration
    for port in `seq 7000 7005`; do
      PORT=${port} envsubst < /redis-conf/redis-cluster.tmpl > /redis-conf/${port}/redis.conf
    done

    /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
    sleep 3

    IP=${IP:-`ifconfig | grep "inet addr" | grep -v "127.0.0.1" | cut -f2 -d ":" | cut -f1 -d " "`}
    echo "yes" | redis-cli --cluster create ${IP}:7000 ${IP}:7001 ${IP}:7002 ${IP}:7003 ${IP}:7004 ${IP}:7005 --cluster-replicas 1
    tail -f /var/log/redis-cli*.log
  fi
else
  exec "$@"
fi
