output "ec2_instance_tags" {
  description = "The tags assigned to the EC2 instance"
  value       = aws_instance.zipmap-lab-instance.tags
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.zipmap-lab-bucket.bucket
}
