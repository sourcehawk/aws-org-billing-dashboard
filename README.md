# Grafana CUR Dashboard for AWS Organizations

![AWS Organization Billing Dashboard](https://ibb.co/G3tnCVw)

This project provides a dashboard and infrastructure for AWS organization cost and usage report. It uses Terraform to provision the infrastructure and Helm to deploy the dashboard. You can also ignore helm entirely and import the dashboard and set the datasource manually.

The project is organized into two main directories:

- `terraform/`: Contains Terraform modules for setting up the AWS infrastructure, including Glue Catalog Database, Glue Crawlers, and an S3 bucket for storing AWS Cost and Usage Reports (CUR). It also includes a Grafana workspace with an Athena data source for visualizing the CUR data.

- `helm/`: Contains Helm chart for deploying the dashboard and datasource.

## Requirements

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/) > 2.0
- [Helm](https://helm.sh/docs/intro/install/) >= 3.1
- [asdf](https://asdf-vm.com/#/core-manage-asdf) Optional - for managing versions of multiple runtime environments
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) Optional - for local Kubernetes cluster setup (make sure to do `asdf reshim golang` after installing kind if using asdf)

## Usage

1. Clone the repository.
2. Navigate to the `terraform/` directory and run `terraform init`, `terraform plan` and `terraform apply` with the appropriate options to provision the AWS infrastructure.
3. In case you have grafana deployed in kubernetes, navigate to the `helm/` directory and deploy the dashboard using Helm. If you have grafana deployed by other means, you can set up the datasource manually using [this documentation](https://grafana.com/grafana/plugins/grafana-athena-datasource/?tab=overview) as reference and import the [dashboards from the helm chart](helm/aws-org-cur-dashboard/dashboards/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
