terraform {
  # Must be configured in us-east-1
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
}
