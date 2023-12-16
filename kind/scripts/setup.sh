CLUSTER_NAME="dev-cluster"
script_dir="$(dirname "$(readlink -f "$0")")"

# Create a cluster
kind create cluster --config "./{script_dir}/kind.config.yaml" --name $CLUSTER_NAME
kubectl config set-context kind-$CLUSTER_NAME

eval "${script_dir}/addons.sh"