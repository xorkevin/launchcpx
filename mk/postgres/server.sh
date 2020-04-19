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

<<EOF
apiVersion: 'kustomize.config.k8s.io/v1beta1'
kind: 'Kustomization'
namespace: ${ns}
namePrefix: ${dbname}-
commonLabels:
  app.kubernetes.io/name: 'postgres'
  app.kubernetes.io/instance: 'postgres'
  app.kubernetes.io/part-of: 'postgres'
  app.kubernetes.io/managed-by: 'launchcpx'
bases:
  - 'github.com/xorkevin/launchcpx/mk/postgres/base'
EOF

if [ ! -z $configdir ]; then
<<EOF
configMapGenerator:
- name: my-application-properties
  files:
  - application.properties
EOF
fi
