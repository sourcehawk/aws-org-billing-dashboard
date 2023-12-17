# Terraform AWS Org Billing Dashboard

This repository contains Terraform code to deploy cost and usage report automation with
an athena querier. Note that once deployed, you will have to wait up to 24 hours to get your first report from AWS.
Some statistics in the dashboard will not be available until you have two months of billing reports.

## Prerequisites

Before you can run the Terraform code, make sure you have the following prerequisites:

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- AWS CLI installed and configured with your AWS account credentials.

## Authorize with AWS Configure SSO

Make sure the account you use is a "management account" in your organization. Otherwise you may not be able to retrieve account information.

To authorize with AWS Configure SSO, follow these steps:

1. Install the AWS CLI v2 if you haven't already. Refer to the [AWS CLI v2 installation guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) for instructions.

2. Configure AWS SSO by running the following command:

```bash
aws configure sso
```

This command will prompt you to select the AWS SSO profile to use and authenticate with your AWS SSO credentials.

3. Once authenticated, you can use the AWS CLI with the configured SSO profile to interact with your AWS resources.

For more information on AWS SSO and how to configure it, refer to the [AWS Single Sign-On User Guide](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html).

## Targets

`<environmemt>.tfbackend` file content:

```
region = "eu-west-1"
bucket = "example-bucket"
key = "athena-glue-cur.tfstate"
```

No newline at end of file!

`<environment>.tfvars` file content:

```hcl
environment = "dev"
```

## Steps to Run Terraform Code

1. Clone this repository to your local machine:

```bash
git clone https://github.com/your-username/aws-org-billing-dashboard.git
```

2. Change into the Terraform directory:

```bash
cd aws-org-billing-dashboard/terraform
```

3. Initialize the Terraform working directory:

```bash
terraform init -backend=targets/dev.tfbackend
```

4. Review the Terraform plan to see what resources will be created:

```bash
terraform plan -var-file=targets/dev.tfvars -out=tfplan
```

5. If everything looks good, apply the Terraform changes:

```bash
terraform apply tfplan
```

You will be prompted to confirm the changes. Enter `yes` to proceed.

6. Wait for Terraform to provision the resources. Once completed, you will see the output with the created resources.

7. Destroy

```bash
terraform destroy -var-file=targets/dev.tfvars
```
