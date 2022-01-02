terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 3.0"
    }
  }

  backend "s3" {
      bucket = "hyun95"
      key = "terraform.tfstate"
      region = "ap-northeast-2"
  }
}

provider "aws" {
    region = "ap-northeast-2"
}
provider "aws" {
    region = "ap-northeast-2"
    alias = "acm_provider"
}

provider "aws" {
    region = "us-east-1"
    alias = "acm_provider2"
}