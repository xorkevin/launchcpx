set -e

. ./mk/source.sh
. ./mk/lib.sh

launchplan_postgres_usage() {
  cat <<EOF 1>&2
USAGE:
    $0 [OPTIONS] <name>

OPTIONS:
    -n <namespace>
        Use the kubernetes namespace.
    -c <init script dir>
        Add init script directory containing *.sql and *.sh files.
    -p <passfile>
        Output password to passfile.
        Default is dbpass.
    -l <length>
        Change the generated password length in terms of bytes of randomness.
        Default is 32.
    -o <file>
        Output config to file.
        Default is stdout.
    -h
        Print this help.

ARGS:
    <name>
        The name prefixes all resources of the postgres deployment.
EOF
}

launchplan_postgres_exit() {
  launchplan_postgres_usage
  exit 2
}

ns=
configdir=
passfile=dbpass
passlen=32
outfile=/dev/stdout
name=

while getopts ':n:c:p:l:o:h' opt; do
 case $opt in
   n) ns="$OPTARG";;
   c) configdir="$OPTARG";;
   p) passfile="$OPTARG";;
   l) passlen=$OPTARG;;
   o) outfile="$OPTARG";;
   h) launchplan_postgres_usage; exit 0;;
   *) launchplan_postgres_exit;;
 esac
done
shift $(($OPTIND - 1))
name="$1"
configfiles=

# validation
if [ -z $name ]; then
  launchplan_postgres_exit
fi

if [ ! -z $configdir ]; then
  if [ ! -d $configdir ]; then
    echo "$configdir is not a directory." 1>&2
    exit 1
  fi
  configfiles=$(find $configdir -type f \( -name '*.sql' -o -name '*.sh' \))
fi

# create password file ifne
secret=postgres-pass
if [ ! -e $passfile ]; then
  launchplan_gen_pass $passlen > $passfile
fi

# generate output
cat <<EOF > $outfile
apiVersion: 'kustomize.config.k8s.io/v1beta1'
kind: 'Kustomization'
EOF

if [ ! -z $ns ]; then
  cat <<EOF >> $outfile
namespace: '${ns}'
EOF
fi

cat <<EOF >> $outfile
namePrefix: '${name}-'
commonLabels:
  app.kubernetes.io/name: 'postgres'
  app.kubernetes.io/instance: 'postgres-${name}'
  app.kubernetes.io/part-of: 'postgres-${name}'
  app.kubernetes.io/managed-by: 'launchcpx'
bases:
  - 'github.com/xorkevin/launchcpx//mk/postgres/base'
secretGenerator:
  - name: postgres-pass
    files:
      - password=${passfile}
    type: Opaque
EOF

if [ ! -z $configfiles ]; then
  cat <<EOF >> $outfile
configMapGenerator:
  - name: 'postgres-initscripts'
    files:
EOF
  for file in $configfiles; do
    echo "      - '${file}'" >> $outfile
  done
fi
