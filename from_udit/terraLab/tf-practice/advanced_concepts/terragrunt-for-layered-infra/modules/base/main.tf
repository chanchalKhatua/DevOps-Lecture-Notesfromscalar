provider "aws" {
    region = "us-west-2" 
}

resource "aws_instance" "example" {
  ami           = "ami-05ee755be0cd7555c"
  instance_type = var.instance_type

  tags = {
    Name = "terragrunt-instance"
  }
}
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.bucket_name}${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket" "example" {
    bucket = "${var.bucket_name}${random_id.bucket_suffix.hex}"

    tags ={
        Name = "terragrunt-bucket"
    }
}