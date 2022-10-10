terraform {
  cloud {
    organization = "rskaradag"

    workspaces {
      name = "jumbo-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key_id
  secret_key = var.secret_access_key
}

