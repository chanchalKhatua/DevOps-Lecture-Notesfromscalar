output "bucket_names" {
  value = [for each in aws_aws_s3_bucket.aws_s3_bucket: each.bucket]
}