terraform {
  
  required_version = ">= 1.3.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44.0" 
      # Or, for a specific version: version = "5.50.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_sns_topic" "lab-sns-topic" {
  name = "lab-sns-topic"

  lifecycle {
    ignore_changes = [tags_all]
  }
 
}