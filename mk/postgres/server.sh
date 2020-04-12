#!/usr/bin/env bash

set -e

. ./mk/source.sh

dbname=${1:-testdb}
username=${2:-vault}
configdir=${3}

password=$(base64 < /dev/urandom | tr +/ -_ | head -c ${PASS_LEN})
secret=${dbname}-postgresql-pass

kubectl create secret generic ${secret} --from-literal=postgresql-password="${password}"

config=${dbname}-postgresql-init
values="postgresqlUsername=${username},postgresqlDatabase=${dbname},existingSecret=${secret}"

if [ ! -z $configdir ]; then
  kubectl create configmap ${config} --from-file=${configdir};
  values="${values},initdbScriptsConfigMap=${config}"
fi

helm install -f mk/postgres/values.yaml --set ${values} ${dbname} bitnami/postgresql
