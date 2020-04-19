#!/usr/bin/env bash

set -e

. ./mk/source.sh

dbname=${1:-testdb}
namespace=${2:-default}
configdir=${3}

password=$(base64 < /dev/urandom | tr +/ -_ | head -c ${PASS_LEN})
secret=${dbname}-postgres-pass

kubectl create secret generic ${secret} --from-literal=password="${password}"

if [ ! -z $configdir ]; then
  echo "has config"
fi
