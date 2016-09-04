#!/bin/bash

echo -e "PostgreSQL access details must be passed as environment variables.\n\
Refer to http://www.postgresql.org/docs/current/static/libpq-envars.html \
for more details\n"

if [ -z "$PGHOST" ]; then
  export PGHOST=$DB_PORT_5432_TCP_ADDR
fi

if [ -z "$PGPORT" ]; then
  export PGPORT=$DB_PORT_5432_TCP_PORT
fi

if [ -z "$PGUSER" ]; then
  export PGUSER=postgres
fi

if [ -z "$PGPASSWORD" ]; then
  export PGPASSWORD=$DB_ENV_POSTGRES_PASSWORD
fi

if [ -z "$CONCOURSE_DB_PASSWORD" ]; then
  >&2 echo "CONCOURSE_DB_PASSWORD is required"
  exit 1
fi

wait-for-it $PGHOST:$PGPORT -t 300
if [ $? -ne 0 ]; then
  echo "ERROR: Unable to connect to PostgreSQL."
  exit 1
fi

psql -c "CREATE DATABASE concourse WITH ENCODING 'utf-8';" || true
psql -c " \
    CREATE USER concourse_admin WITH LOGIN ENCRYPTED PASSWORD '$CONCOURSE_DB_PASSWORD';\
    GRANT ALL PRIVILEGES ON DATABASE concourse TO concourse_admin;" || true

echo "Finished"
