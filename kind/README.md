# Local kubernetes

The `kind/` folder contains scripts and configuration files for setting up a Kubernetes cluster using [kind (Kubernetes in Docker)](https://kind.sigs.k8s.io/).

## Prerequisites

- Docker: Make sure Docker is installed on your machine. You can download Docker from [here](https://www.docker.com/products/docker-desktop).
- kind: Install kind by following the instructions [here](https://kind.sigs.k8s.io/docs/user/quick-start/#installation).

## Setup

1. Run the `setup.sh` script to set up the Kubernetes cluster. This script installs the necessary dependencies and tools, configures the cluster by creating the necessary resources, and deploys the applications and services onto the cluster. Grafana will be exposed at [localhost:4000](http://localhost:4000)

   ```bash
   ./setup.sh
   ```

## Teardown

2. Run the `teardown.sh` script to tear down the Kubernetes cluster. This script deletes all the resources associated with the cluster and cleans up any remaining dependencies and tools.

   ```bash
   ./teardown.sh
   ```

Please make sure you understand the consequences of tearing down the cluster before executing the `teardown.sh` script.

## Commands

Install helm: `helm upgrade --install aws-cur ./helm/aws-org-cur-dashboard -f ./helm/aws-org-cur-dashboard/ci/secretstore-cluster-values.yaml`

Get secret value: `kubectl get secret athena-datasource -o jsonpath='{.data.datasource\.yaml}' | base64 --decode`
