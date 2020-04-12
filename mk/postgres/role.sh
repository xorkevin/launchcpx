#!/usr/bin/env bash

set -e

. ./mk/source.sh

dbname=${1:-testdb}
ttl=${2:-1h}
maxttl=${3:-24h}

secret=${dbname}-postgresql-pass
password=$(kubectl get secrets/${secret} -o json | jq -r '.data["postgresql-password"]' | base64 -d)

role=${dbname}-role

vault write database/config/${dbname} \
  plugin_name="postgresql-database-plugin" \
  allowed_roles="${role}" \
  connection_url="postgresql://{{username}}:{{password}}@${dbname}-postgresql.default.svc.cluster.local:5432/${dbname}?sslmode=disable" \
  username="postgres" \
  password="${password}"

vault write database/roles/${role} \
  db_name="${dbname}" \
  creation_statements=@mk/postgres/rolecreate.sql \
  revocation_statements=@mk/postgres/rolerevoke.sql \
  default_ttl="${ttl}" \
  max_ttl="${maxttl}"
