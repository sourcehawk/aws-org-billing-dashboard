variable "environment" {
  type        = string
  description = "Unique identifier for the environment"
}


locals {
  account_mappings = {
    for account in data.aws_organizations_organization.current.accounts : account.id => account.name
  }
}


locals {
  report_name         = "cur-${var.environment}"  # Name of the report in S3
  crawler_lambda_name = "cur_crawler_initializer" # Name of python file
  report_s3_prefix    = "billing-report/${var.environment}"
  account_table_name  = "account_names"
  csv_content = join("\n", [
    for account_id, account_name in local.account_mappings : "${account_id},${account_name}"
  ])
}
