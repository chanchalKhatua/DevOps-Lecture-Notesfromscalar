# Main Terraform Configuration
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

  resource "random_id" "bucket_suffix" {
    byte_length = 4
  }

  resource "time_static" "created" {}

  locals {
        formatted_timestamp = formatdate("YYYYMMDD-HHmmss", time_static.created.rfc3339)
        bucket_name         = "demo-bucket-${random_id.bucket_suffix.hex}-${local.formatted_timestamp}"
  }

  resource "aws_s3_bucket" "bucket" {
  bucket = local.bucket_name
  force_destroy = true

  tags = {
    Name        = local.bucket_name
    Environment = "Dev"
    }
  }

  output "generated_bucket_name" {
  description = "The name of the S3 bucket that was created"
  value       = aws_s3_bucket.bucket.bucket
}