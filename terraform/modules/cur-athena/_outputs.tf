output "athena_access_iam_policy_arn" {
  value       = aws_iam_policy.athena_access.arn
  description = "ARN of the IAM policy that grants the required permissions to query CUR with Athena."
}
