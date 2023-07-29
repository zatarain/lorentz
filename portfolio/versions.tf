terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5"
      configuration_aliases = [ aws, aws.root ]
    }
  }
}
