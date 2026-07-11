provider "aws" {
  region = "us-west-2"
}

resource "random_id" "bucket_suffix" {
    byte_length = 4
}

resource "aws_s3_bucket" "aws_s3_bucket" {
    for_each = var.buckets
    bucket = "${each.key}-${random_id.bucket_suffix.hex}"

    tags ={
        Name = each.key
        Description = each.value
    }
}