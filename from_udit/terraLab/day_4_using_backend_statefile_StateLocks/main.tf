provider "aws" {
    region = "ap-south-1"
  
}

resource "aws_instance" "instance_1" {
    ami = "ami-0614680123427b75e"  # amazon image ami.
    # ami ="ami-0dee22c13ea7a9a67" # Ubuntu image ami; to check the versioning and update of tfstate file in s3.
    instance_type = "t2.micro"

}

resource "aws_s3_bucket" "s3_bucket" {
    bucket ="terralab-day4-28112024-2239"
    force_destroy = true
  
}

resource "aws_s3_bucket_versioning" "versioning_s3_bucket" {
    bucket = aws_s3_bucket.s3_bucket.id
    versioning_configuration {
        status = "Enabled"
  }
}