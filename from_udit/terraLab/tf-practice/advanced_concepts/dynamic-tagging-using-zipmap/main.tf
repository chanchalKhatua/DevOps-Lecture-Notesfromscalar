provider "aws" {
  region = "us-west-2"
}

locals {
  # This local value creates a map named 'common_tags'
  # by zipping together the elements of 'var.tag_keys' (as keys)
  # and 'var.tag_values' (as values).
  common_tags = zipmap(var.tag_keys, var.tag_values)
}

resource "aws_instance" "zipmap-lab-instance" {
  ami           = "ami-05ee755be0cd7555c"
  instance_type = "t3.micro"

  tags = local.common_tags
}

resource "random_id" "bucket_suffix" {
    byte_length = 4
}

locals {
    bucket_name = "zipmap-lab-bucket-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket" "zipmap-lab-bucket" {
  bucket = local.bucket_name

  tags = local.common_tags
}