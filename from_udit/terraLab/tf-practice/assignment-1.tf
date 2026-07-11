provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "testing-bucket-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "testing-bucket-${data.aws_caller_identity.current.account_id}"
    Environment = "testing"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
