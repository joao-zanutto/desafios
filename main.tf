terraform {
  required_version = ">= 1.1.8"
  backend "s3" {
    bucket = "metabase-tfstate"
    key    = "tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  region = "us-east-1"
}
