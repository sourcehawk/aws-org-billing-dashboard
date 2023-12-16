output "accounts" {
  value       = module.glue_db.accounts
  description = "A list of AWS account IDs that are included in the cost and usage report."
}

output "athena_access_iam_policy_arn" {
  value       = module.athena_for_grafana.athena_access_iam_policy_arn
  description = "ARN of the IAM policy that grants the required permissions to query CUR with Athena."
}
