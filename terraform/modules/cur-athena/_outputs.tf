output "athena_access_iam_policy_arn" {
  value       = aws_iam_policy.athena_access.arn
  description = "ARN of the IAM policy that grants the required permissions to query CUR with Athena."
}

output "secret_id" {
  value = var.create_secret ? aws_secretsmanager_secret.athena_user_access_key_secret[0].id : null
}
