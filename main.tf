terraform {
  backend "s3" {
    bucket         = "lorentz-production-state"
    key            = "production/lorentz.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "lorentz-production-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

module "terraform-state" {
  source = "./terraform-state"
  name   = "lorentz-production"
}
