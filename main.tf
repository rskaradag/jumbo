terraform {
  backend "s3" {
    bucket = "myjumbo"
    key    = "assesment/key"
    region = "eu-central-1"
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
  region = "${var.aws_region}"
}

