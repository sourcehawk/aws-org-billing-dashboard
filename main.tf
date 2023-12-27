terraform {
  backend "s3" {}
}

variable "environment" {
  type        = string
  description = "The environment name"
}

provider "aws" {
  region = "us-east-1" # CUR is only available in us-east-1
  default_tags {
    tags = {
      "project"     = "https://github.com/sourcehawk/aws-org-billing-dashboard"
      "environment" = var.environment
    }
  }
}

module "aws_cur" {
  source = "./terraform"
  # source = "git@github.com:sourcehawk/aws-org-billing-dashboard.git//terraform?ref=1.0.0"

  environment   = var.environment
  create_secret = true
  secret_name   = "aws-org-billing-dashboard/grafana-athena-datasource"
}
