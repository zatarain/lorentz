terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.92.0"
      configuration_aliases = [aws, aws.root]
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.6"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.6"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36.0"
    }
  }
}
