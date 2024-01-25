variable "environment" {
  type        = string
  description = "Unique identifier for the environment"
}

variable "billing_report_bucket_name" {
  type        = string
  description = "Name of the S3 bucket where the billing reports are stored"
}

variable "glue_catalog_database_name" {
  type        = string
  description = "Name of the Athena database holding the billing reports"
}

variable "create_secret" {
  type        = bool
  description = "Whether or not to create a secret with an IAM access keys in AWS Secrets Manager"
  default     = true
}

variable "secret_name" {
  type        = string
  description = "(Optional) Name of the AWS Secrets Manager secret to hold the datasource credentials"
  default     = "grafana-athena-datasource"
}
