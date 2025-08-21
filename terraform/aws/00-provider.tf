terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.73.0"
    }
  }
  backend "s3" {
    bucket         = "guardsec-tf-s3"
    key            = "tfstate"
    dynamodb_table = "guardsec-tf-dynamo"
    region         = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}