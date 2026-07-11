output "static_website_url" {
  value = "http://${aws_s3_bucket.StaticWebsite.bucket}.s3-website-${var.region}.amazonaws.com"
}