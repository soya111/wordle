terraform {
  required_version = ">= 0.12.28"
  backend "s3" {
  }
  required_providers {
    aws = ">= 4.0.2"
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-northeast-1"
}
