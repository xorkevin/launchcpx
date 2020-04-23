export BIN_NAME='flightctl plan'

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
