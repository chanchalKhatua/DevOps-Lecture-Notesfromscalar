output "generated_bucket_name" {
  description = "The name of the S3 bucket that was created"
  value       = aws_s3_bucket.bucket.bucket
}
