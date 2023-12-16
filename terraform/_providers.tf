provider "aws" {
  region = "us-east-1" # CUR is only available in us-east-1
  default_tags {
    tags = {
      "project"     = "https://github.com/hauks96/aws-org-billing-dashboard"
      "environment" = var.environment
    }
  }
}

