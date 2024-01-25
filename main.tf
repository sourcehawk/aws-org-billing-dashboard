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

# I want to upload the secrets to eu-west-1 and not us-east-1
provider "aws" {
  alias  = "secrets_provider"
  region = "eu-west-1"
}

module "aws_cur" {
  source = "./terraform"
  # source = "git@github.com:sourcehawk/aws-org-billing-dashboard.git//terraform?ref=1.0.0"

  environment   = var.environment
  create_secret = true
  secret_name   = "aws-org-billing-dashboard/grafana-athena-datasource"

  providers = {
    aws                  = aws
    aws.secrets_provider = aws.secrets_provider
  }
}
