#!/usr/bin/env bash

set -e

. ./mk/source.sh

dbname=${1:-testdb}
username=${2:-vault}
ttl=${3:-1h}
maxttl=${4:-24h}

secret=${dbname}-postgresql-pass
password=$(kubectl get secrets/${secret} -o json | jq -r '.data["postgresql-password"]' | base64 -d)

role=${dbname}-role

vault write database/config/${dbname} \
  plugin_name="postgresql-database-plugin" \
  allowed_roles="${role}" \
  connection_url="postgresql://{{username}}:{{password}}@${dbname}-postgresql.default.svc.cluster.local:5432/${dbname}?sslmode=disable" \
  username="${username}" \
  password="${password}"

vault write database/roles/${role} \
  db_name="${dbname}" \
  creation_statements="CREATE ROLE '{{name}}' WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO '{{name}}'; \
    GRANT CREATE ON SCHEMA public TO '{{name}}';" \
  revocation_statements="DROP ROLE IF EXISTS '{{name}}';" \
  rollback_statements="DROP ROLE IF EXISTS '{{name}}';" \
  renew_statements="ALTER ROLE '{{name}}' WITH VALID UNTIL '{{expiration}}';" \
  rotation_statements="ALTER ROLE '{{name}}' WITH PASSWORD '{{password}}';" \
  default_ttl="${ttl}" \
  max_ttl="${maxttl}"
