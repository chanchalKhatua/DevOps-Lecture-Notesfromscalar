
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "lifecycle-managed-bucket-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket" "lifecycle_bucket" {
  bucket = local.bucket_name
  # Do not force destroy
  force_destroy = false
  tags = {
    Name        = local.bucket_name
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.lifecycle_bucket.id

  rule {
    id     = "transition-to-ia-and-glacier"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}
