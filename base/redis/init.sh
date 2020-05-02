#!/bin/sh

set -e

echo2() {
  echo "$@" 1>&2
}

read_satoken() {
  cat /var/run/secrets/kubernetes.io/serviceaccount/token
}

auth_vault_req() {
  local satoken=$1
  local role=$2

  cat <<EOF
{ "jwt": "${satoken}", "role": "${role}" }
EOF
}

auth_vault() {
  local satoken=$(read_satoken)
  echo2 'read service account token'
  local req=$(auth_vault_req $satoken $VAULT_ROLE)
  curl -s -X POST -d "$req" "${VAULT_ADDR}/v1/auth/kubernetes/login" \
    | jq -r '.auth.client_token'
}

vault_kvput_req() {
  local val=$1
  cat <<EOF
{ "data": $val }
EOF
}

vault_kvput() {
  local token=$1
  local key=$2
  local val=$3

  local req=$(vault_kvput_req $val)
  curl -s \
    -H "X-Vault-Token: ${token}" \
    -X POST -d "$req" \
    "${VAULT_ADDR}/v1/${key}" > /dev/null
}

gen_pass() {
  local passlen=$1
  head -c $passlen < /dev/urandom | base64 | tr -d '\n=' | tr '+/' '-_'
}

echo2 'begin genpass'

pass=$(gen_pass ${PASS_LEN:-64})
echo2 'generate password'

token=$(auth_vault)
echo2 'authenticate with vault'

vault_kvput $token $KV_PATH "{\"password\": \"${pass}\"}"
echo2 'write password to vault kv'

cat <<EOF > /etc/redispass/pass.conf
requirepass ${pass}
EOF
echo2 'write password to redis conf'
