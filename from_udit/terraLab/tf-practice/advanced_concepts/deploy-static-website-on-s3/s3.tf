resource "random_id" "bucket_suffix" {
    byte_length = 4
}

locals{
    bucket_name = "static-site-example-bucket-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket" "StaticWebsite" {
    bucket = local.bucket_name

    tags ={
        Name = "StaticWebsite"
    }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  bucket = aws_s3_bucket.StaticWebsite.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_website_configuration" "bucket_website_configuration" {
  bucket = aws_s3_bucket.StaticWebsite.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.StaticWebsite.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${local.bucket_name}/*"
    }
  ]
}
POLICY
  depends_on = [aws_s3_bucket_public_access_block.bucket_public_access]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.StaticWebsite.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.StaticWebsite.id
  key          = "error.html"
  source       = "${path.module}/error.html"
  content_type = "text/html"
}