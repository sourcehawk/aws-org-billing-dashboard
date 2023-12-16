# cur-glue-database Terraform Module

This Terraform module creates an AWS Glue Catalog Database and an S3 bucket for storing AWS Cost and Usage Reports (CUR). The Glue Catalog Database is used to store the metadata of the CUR data stored in the S3 bucket. A crawler is configured to automatically discover and populate the Glue Catalog Database with the schema of the CUR data. This allows for easy querying and analysis of the CUR data using AWS Glue and other AWS services such as Athena.

## Usage

```hcl
module "cur_glue_database" {
  source = "./modules/cur-glue-database"

  environment = "my-account"
}
```

## Inputs

| Name        | Description                           | Type     | Default | Required |
| ----------- | ------------------------------------- | -------- | ------- | :------: |
| environment | Unique identifier for the environment | `string` | n/a     |   yes    |

## Outputs

| Name                       | Description                                                              |
| -------------------------- | ------------------------------------------------------------------------ |
| glue_catalog_database_name | The name of the AWS Glue catalog database for the cost and usage report. |
| billing_report_bucket_name | The name of the S3 bucket where billing reports are stored.              |

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 1.6.5  |
| aws       | >= 2.14.5 |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | >= 5.0  |

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
