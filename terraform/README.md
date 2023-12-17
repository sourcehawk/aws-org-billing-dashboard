# Terraform AWS Org Billing Dashboard

This repository contains Terraform code to deploy cost and usage report automation with an Athena querier. Please note that it may take up to 24 hours to receive your first report from AWS after deployment. Additionally, some statistics in the dashboard will only be available once you have two months of billing reports.

## Authorize with AWS Configure SSO

Make sure that the account you use is a "management account" in your organization. Otherwise, you may not be able to retrieve account information.

To authorize with AWS Configure SSO, follow these steps:

1. If you haven't already, install the AWS CLI v2. Refer to the [AWS CLI v2 installation guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) for instructions.

2. The following command will prompt you to select the AWS SSO profile to use and authenticate with your AWS SSO credentials.:

   > aws configure sso

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

_this is just an example, you can run it however you please_

1. Clone this repository to your local machine:

   > git clone https://github.com/sourcehawk/aws-org-billing-dashboard.git

2. Change into the Terraform directory:

   > cd aws-org-billing-dashboard/terraform

3. Initialize the Terraform working directory:

   > terraform init -backend=targets/dev.tfbackend

4. Review the Terraform plan to see what resources will be created:

   > terraform plan -var-file=targets/dev.tfvars -out=tfplan

5. If everything looks good, apply the Terraform changes:

   > terraform apply tfplan

6. Wait for Terraform to provision the resources. Once completed, you will see the output with the created resources.

7. Destroy

   > terraform destroy -var-file=targets/dev.tfvars
