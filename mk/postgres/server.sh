#!/usr/bin/env bash

set -e

. ./mk/source.sh
. ./mk/lib.sh

ns=${1:-${NAMESPACE}}
dbname=${2:-testdb}
configdir=${3}
passfile=${4:-dbpass}

create_ns_ifne $ns

# create password file ifne
secret=postgres-pass
if [ ! -e $passfile ]; then
  gen_pass ${PASS_LEN} > $passfile
fi

cat <<EOF
apiVersion: 'kustomize.config.k8s.io/v1beta1'
kind: 'Kustomization'
namespace: '${ns}'
namePrefix: '${dbname}-'
commonLabels:
  app.kubernetes.io/name: 'postgres'
  app.kubernetes.io/instance: 'postgres'
  app.kubernetes.io/part-of: 'postgres'
  app.kubernetes.io/managed-by: 'launchcpx'
bases:
  - 'github.com/xorkevin/launchcpx/mk/postgres/base'
secretGenerator:
  - name: postgres-pass
    files:
      - password=${passfile}
    type: Opaque
EOF

if [ ! -z $configdir ]; then
  files=$(find $configdir -type f \( -name '*.sql' -o -name '*.sh' \))
  if [ ! -z $files ]; then
    cat <<EOF
configMapGenerator:
  - name: 'postgres-initscripts'
    files:
EOF
    for file in $files; do
      echo "      - '${file}'"
    done
  fi
fi
