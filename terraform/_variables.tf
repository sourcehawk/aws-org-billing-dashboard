variable "environment" {
  type        = string
  description = "Unique identifier for the environment"
}

variable "create_secret" {
  type        = bool
  description = "Whether to create a secret for the Athena datasource. Creates an IAM user and access key if true"
  default     = true
}

variable "secret_name" {
  type        = string
  description = "Name of the secret to create"
  default     = "grafana-athena-datasource"
}
