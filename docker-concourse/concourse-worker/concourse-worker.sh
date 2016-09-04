#!/bin/bash

if [ -z "$CONCOURSE_TSA_HOST" ]; then
  >&2 echo "CONCOURSE_TSA_HOST is required"
  exit 1
fi

wait-for-it $CONCOURSE_TSA_HOST:$CONCOURSE_TSA_PORT -t 300 -- sleep 3
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to connect to Concourse ATC/TSA."
  exit 1
fi

/usr/local/bin/dumb-init concourse worker \
  --work-dir /opt/concourse \
  --tsa-host $CONCOURSE_TSA_HOST \
  --tsa-port $CONCOURSE_TSA_PORT \
  --tsa-public-key host_key.pub \
  --tsa-worker-private-key worker_key \
  $@
