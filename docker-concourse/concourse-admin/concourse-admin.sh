#!/bin/sh

set -e

export PGUSER=$CONCOURSE_DB_USER
export PGPASSWORD=$CONCOURSE_DB_PASSWORD

args=""

if [ -z "$CONCOURSE_DB_USER" ]; then
  export PGUSER=concourse_admin
fi

if [ -z "$CONCOURSE_DB_HOST" ]; then
  export CONCOURSE_DB_HOST=$DB_PORT_5432_TCP_ADDR
fi

if [ -z "$CONCOURSE_DB_PORT" ]; then
  export CONCOURSE_DB_PORT=$DB_PORT_5432_TCP_PORT
fi

if [ -n "$CONCOURSE_GITHUB_CLIENT" ]; then
  args="$args --github-auth-client-id $CONCOURSE_GITHUB_CLIENT"
fi

if [ -n "$CONCOURSE_GITHUB_SECRET" ]; then
  args="$args --github-auth-client-secret $CONCOURSE_GITHUB_SECRET"
fi

if [ -n "$CONCOURSE_GITHUB_ORG" ]; then
  args="$args --github-auth-organization $CONCOURSE_GITHUB_ORG"
  args="$args --github-auth-team $CONCOURSE_GITHUB_ORG/all"
fi

export CONCOURSE_DB_URL=postgres://$PGUSER:$PGPASSWORD@$CONCOURSE_DB_HOST:$CONCOURSE_DB_PORT/$CONCOURSE_DB?sslmode=disable

wait-for-it $CONCOURSE_DB_HOST:$CONCOURSE_DB_PORT -t 300
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to connect to PostgreSQL."
  exit 1
fi

/usr/local/bin/dumb-init concourse web \
  --session-signing-key session_signing_key \
  --tsa-host-key host_key \
  --tsa-authorized-keys authorized_worker_keys \
  --peer-url http://$CONCOURSE_PEER_URL:8080 \
  --postgres-data-source $CONCOURSE_DB_URL \
  --external-url $CONCOURSE_URL \
  $args \
  $@
