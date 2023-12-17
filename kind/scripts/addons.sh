script_dir="$(dirname "$(readlink -f "$0")")"

# Add required repositories
helm repo add external-secrets https://charts.external-secrets.io
helm repo add traefik https://helm.traefik.io/traefik
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install traefik on cluster
helm upgrade --install traefik traefik/traefik --version "26.0.0" -n traefik --create-namespace \
  -f "${script_dir}/../resources/traefik.values.yaml" --wait

# Install grafana on cluster
helm upgrade --install grafana grafana/grafana --version "7.0.14" -f "${script_dir}/../resources/grafana.values.yaml" --wait

# Install external-secrets on cluster
helm upgrade --install external-secrets external-secrets/external-secrets --version "0.9.9" --wait

# Create fake secretstores on cluster
kubectl apply -f "${script_dir}/../resources/fake.secretstores.yaml"
