# cur-athena Terraform Module

This Terraform module creates a workgroup for Athena. This allows us to visualize and analyze AWS Cost and Usage Report (CUR) data stored in an AWS Glue Catalog Database by querying with SQL through an athena datasource in grafana.

A second provider should be defined for the created secret uploaded to secrets manager. This is to give more control over where the secrets are since the other resources must be created in the us-east-1 region.

## Usage

```hcl
module "athena_for_grafana" {
  source                     = "./modules/cur-athena"
  environment                = var.environment
  billing_report_bucket_name = module.glue_db.billing_report_bucket_name
  glue_catalog_database_name = module.glue_db.catalog_database_name

  create_secret = true
  secret_name   = "grafana-athena-datasource"

  providers = {
    aws = aws.us-east-1
    aws.secrets_provider = aws.eu-west-1
  }
}
```

## Inputs

| Name                       | Description                           | Type     | Default                   | Required |
| -------------------------- | ------------------------------------- | -------- | ------------------------- | :------: |
| environment                | Unique identifier for the environment | `string` | n/a                       |   yes    |
| billing_report_bucket_name | Name of the billing report bucket     | `string` | n/a                       |   yes    |
| glue_catalog_database_name | Name of the Glue catalog database     | `string` | n/a                       |   yes    |
| create_secret              | Flag to create a secret               | `bool`   | true                      |    no    |
| secret_name                | Name of the secret                    | `string` | grafana-athena-datasource |    no    |

## Outputs

| Name                         | Description                                                                              |
| ---------------------------- | ---------------------------------------------------------------------------------------- |
| athena_access_iam_policy_arn | ARN of the IAM policy that grants access to Athena, workspace and S3                     |
| secret_id                    | Id of the secret that contains the datasource credentials. Null if create_secret = fales |

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 1.6.5  |
| aws       | >= 2.14.5 |

## Providers

| Name                 | Version |
| -------------------- | ------- |
| aws                  | >= 5.0  |
| aws.secrets_provider | >= 5.0  |

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
