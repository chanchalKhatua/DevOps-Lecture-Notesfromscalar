resource "aws_s3_bucket" "bucket" {
    bucket = "my-unique-bucket-name-240320260003"
    force_destroy = true

    tags = {
        Name        = "my-unique-bucket-name-240320260003"
        Environment = "Dev"
    }
}