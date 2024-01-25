terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
      configuration_aliases = [
        aws.secrets_provider
      ]
    }
  }
}
