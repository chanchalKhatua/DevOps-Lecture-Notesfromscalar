provider "aws" {
    region = "us-east-1"

}

resource "random_id" "bucket_suffix" {
    byte_length = 4
}


resource "aws_s3_bucket" "demo-bucket" {
    bucket = "demo-bucket-${random_id.bucket_suffix.hex}"
    force_destroy = true

    tags = {
        Name        = "demo-bucket-${random_id.bucket_suffix.hex}"
        Environment = "Dev"
    }
}

output "demo-bucket-name" {
    description = "The name of the S3 bucket that was created"
    value       = aws_s3_bucket.demo-bucket.bucket
  
}