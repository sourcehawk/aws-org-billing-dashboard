# cur-aws Terraform Module

This Terraform module creates the necessary infrastructure for AWS cost and usage report monitoring with grafana.

## Usage

```hcl
module "aws_cur" {
  source = "git@github.com:sourcehawk/aws-org-billing-dashboard.git//terraform?ref=1.0.0"

  environment   = "dev"
  create_secret = true
  secret_name   = "aws-org-billing-dashboard/grafana-athena-datasource"
}
```

## Inputs

| Name          | Description                           | Type     | Default                   | Required |
| ------------- | ------------------------------------- | -------- | ------------------------- | :------: |
| environment   | Unique identifier for the environment | `string` | n/a                       |   yes    |
| create_secret | Flag to create a secret               | `bool`   | true                      |    no    |
| secret_name   | Name of the secret                    | `string` | grafana-athena-datasource |    no    |

## Outputs

| Name                         | Description                                                                              |
| ---------------------------- | ---------------------------------------------------------------------------------------- |
| athena_access_iam_policy_arn | ARN of the IAM policy that grants access to Athena, workspace and S3                     |
| accounts                     | A list of AWS account IDs that are included in the cost and usage report                 |
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
