#!/bin/sh

set -e

export ROOT_DIR=${0%/*}

. "${ROOT_DIR}/_init_lib.sh"

log2 'begin genpass'

pass=$(gen_pass "${PASS_LEN:-64}")
log2 'generate password'

while true; do
  export VAULT_TOKEN=
  i=0
  while [ $i -lt "${CURL_REAUTH:-12}" ]; do
    if [ -z $VAULT_TOKEN ]; then
      export VAULT_TOKEN=$(auth_vault)
      log2 'authenticate with vault'
    fi

    status=$(vault_kvput "$KV_PATH" "{\"password\": \"${pass}\"}")
    if is_success "$status"; then
      log2 'write password to vault kv'
      break 2
    fi
    log2 'error write password to vault kv:' "$(cat /tmp/curlres.txt)"

    i=$((i + 1))
    sleep "${CURL_BACKOFF:-5}"
  done
done

cat <<EOF > /etc/redispass/pass.conf
requirepass ${pass}
EOF
log2 'write password to redis conf'
