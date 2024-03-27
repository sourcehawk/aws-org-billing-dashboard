## AWS Organization Billing Dashboard

This project provides a dashboard and infrastructure for AWS organization cost and usage reports. It uses Terraform to provision the infrastructure and Helm to deploy the dashboard. Alternatively, you can import the dashboard and set the datasource manually.

Please note that some statistics in the dashboard will only be available once you have two months of billing reports.

![AWS Organization Billing Dashboard](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*RqYB67hcoPy0sKmbLL0rpQ.png)

### Project Structure

The project is organized into two main directories:

- `terraform/`: Contains Terraform modules for setting up the AWS infrastructure, including Glue Catalog Database, Glue Crawlers, and an S3 bucket for storing AWS Cost and Usage Reports (CUR). It also includes a Grafana workspace with an Athena data source for visualizing the CUR data.

- `charts/`: Contains Helm chart for deploying the dashboard and datasource.

### Requirements

To use this project, you will need the following:

| Requirement                                             | Required | Description                                                         |
| ------------------------------------------------------- | -------- | ------------------------------------------------------------------- |
| [Terraform](https://www.terraform.io/downloads.html)    | Yes      | To deploy infrastructure                                            |
| [AWS CLI](https://aws.amazon.com/cli/)                  | Yes      | To use terraform with aws provider                                  |
| [Helm](https://helm.sh/docs/intro/install/)             | No       | If you want to deploy the dashboard to Grafana hosted in Kubernetes |
| [asdf](https://asdf-vm.com/#/core-manage-asdf)          | No       | For managing versions of multiple runtime environments              |
| [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) | No       | For local Kubernetes cluster setup.                                 |
| [kubectl](https://kubernetes.io/docs/tasks/tools/)      | No       | For interacting with Kubernetes clusters                            |

### Usage

To use this project, follow these steps:

1. Clone the repository.
2. Authorize with the AWS CLI against a "management account" in your organization. (Will not be able to retrieve org data unless management account)
3. Modify the `example.tfbackend` and `example.tfvars` at the root of the project to conform with your backend and target environment

- `terraform init -backend-config=targets/example.tfbackend`
- `terraform plan -var-file=targets/example.tfvars -out=tfplan`
- `terraform apply tfplan`

4. If you have Grafana deployed in Kubernetes, navigate to the `charts/` directory and deploy the dashboard using Helm with the appropriate values. Alternatively, if you have Grafana deployed by other means, you can set up the datasource manually using [this documentation](https://grafana.com/grafana/plugins/grafana-athena-datasource/?tab=overview) as a reference and import the dashboards from the Helm chart.

Please note that it may take up to 24 hours to receive your first report from AWS after deployment. Additionally, some statistics in the dashboard will only be available once you have two months of billing reports.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
