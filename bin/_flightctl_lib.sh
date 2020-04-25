export VAULT_ADDR=${VAULT_ADDR:-http://127.0.0.1:8200/}

gen_pass() {
  # passlen is bytes of randomness
  # base64 encode is 4/3 times longer
  local passlen=$1
  head -c $passlen < /dev/urandom | base64 | tr -d = | tr +/ -_
}

check_ns() {
  local ns=$1
  kubectl get ns -o=name | grep "namespace/${ns}"
}

create_ns_ifne() {
  local ns=$1
  if [ -z $(check_ns $ns) ]; then
    kubectl create namespace $ns 1>&2
  fi
}

connect_write_app_policy() {
  policydir=$1
  ns=$2
  name=$3

  appname=${ns}-${name}
  policyfiles=$(find $policydir -type f -name '*.policy.hcl')
  cat $policyfiles | vault policy write ${appname} -
}

connect_write_kube_role() {
  ns=$1
  name=$2
  ttl=$3
  maxttl=$4

  appname=${ns}-${name}
  role=${appname}-role
  vault write auth/kubernetes/role/${role} \
    bound_service_account_names="$name" \
    bound_service_account_namespaces="$ns" \
    policies="$appname" \
    ttl="$ttl" \
    max_ttl="$maxttl"
}
