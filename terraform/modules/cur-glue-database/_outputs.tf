output "glue_catalog_database_name" {
  value       = aws_glue_catalog_database.cost_and_usage_report_db.name
  description = "The name of the AWS Glue catalog database for the cost and usage report."
}

output "billing_report_bucket_name" {
  value       = aws_s3_bucket.billing_report_bucket.id
  description = "The name of the S3 bucket where billing reports are stored."
}

output "accounts" {
  value       = local.account_mappings
  description = "A list of AWS account IDs that are included in the cost and usage report."
}
