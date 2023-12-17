data "aws_s3_bucket" "athena_billing_report_bucket" {
  bucket = var.billing_report_bucket_name
}
