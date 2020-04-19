#!/usr/bin/env bash

set -e

. ./mk/source.sh
. ./mk/lib.sh

ns=${1:-${NAMESPACE}}
dbname=${2:-testdb}
configdir=${3}

create_ns_ifne $ns

# create secret ifne
secret=${dbname}-postgres-pass
if [ -z $(check_secret $ns $secret) ]; then
  password=$(gen_pass ${PASS_LEN})
  kubectl -n $ns create secret generic ${secret} \
    --from-literal=password="${password}" \
    1>&2;
fi

if [ ! -z $configdir ]; then
  echo "has config"
fi
