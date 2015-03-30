#!/bin/bash
set -e

if [ "$1" == "google-fluentd" ]; then
  export LD_PRELOAD=/opt/google-fluentd/embedded/lib/libjemalloc.so
  ulimit -n 65536
  exec /opt/google-fluentd/embedded/bin/ruby /usr/sbin/google-fluentd \
    --log /var/log/google-fluentd/google-fluentd.log --use-v1-config
else
  exec "$@"
fi
