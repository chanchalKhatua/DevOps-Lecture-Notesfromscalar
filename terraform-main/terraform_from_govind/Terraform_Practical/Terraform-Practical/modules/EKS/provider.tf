# Configure the AWS Provider
provider "aws" {
  region = var.Region
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
    }
  }
  required_version = ">= 1.1"
}