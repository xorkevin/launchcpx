#!/usr/bin/env bash

set -e

export VAULT_ADDR=${VAULT_ADDR:-http://127.0.0.1:8200/}

name=${1:-testdb}
ttl=${2:-1h}
maxttl=${3:-24h}

secret=${name}-postgres-pass
password=$(kubectl get secrets/${secret} -o=json | jq -r '.data["password"]' | base64 -d)

role=${name}-role

vault write database/config/${name} \
  plugin_name="postgresql-database-plugin" \
  allowed_roles="${role}" \
  connection_url="postgresql://{{username}}:{{password}}@${name}-postgresql.default.svc.cluster.local:5432/${name}?sslmode=disable" \
  username="postgres" \
  password="${password}"

vault write database/roles/${role} \
  db_name="${name}" \
  creation_statements=@mk/postgres/rolecreate.sql \
  revocation_statements=@mk/postgres/rolerevoke.sql \
  default_ttl="${ttl}" \
  max_ttl="${maxttl}"
