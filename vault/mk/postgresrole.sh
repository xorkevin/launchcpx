#!/usr/bin/env bash

. ./mk/source.sh

dbname=${1:-testdb}
username=${2:-vault}
ttl=${3:-1h}
maxttl=${4:-24h}
passlen=${5:-32}

role=${dbname}-role
password=$(base64 < /dev/urandom | tr +/ -_ | head -c ${passlen})

kubectl create secret generic ${dbname}-postgresql-pass --from-literal=postgresql-password="${password}"

vault write database/config/${dbname} \
  plugin_name="postgresql-database-plugin" \
  allowed_roles="${role}" \
  connection_url="postgresql://{{username}}:{{password}}@${dbname}-postgresql.default.svc.cluster.local:5432/?sslmode=disable" \
  username="${username}" \
  password="${password}"

vault write database/roles/${role} \
  db_name="${dbname}" \
  creation_statements="CREATE ROLE '{{name}}' WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
      GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO '{{name}}'; \
      GRANT CREATE ON SCHEMA public TO '{{name}}';" \
  default_ttl="${ttl}" \
  max_ttl="${maxttl}"
