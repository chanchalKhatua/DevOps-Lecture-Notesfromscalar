terraform {
  required_version = ">= 0.12"
  required_providers {
    aws ={
        version = "~> 5.0"
        source = "hashicorp/aws"
    }
  }
}


provider "aws" {
    region = "us-east-1"
    access_key ="<ACCESS_KEY>"
    secret_key = "<SECRET_KEY>"
}