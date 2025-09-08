terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  alias  = "kr"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us"
}
