output "vpc_id" {
  description = "VPC ID to be imported"
  value       = aws_vpc.existing_vpc.id
}

output "subnet_id" {
  description = "Subnet ID to be imported"
  value       = aws_subnet.existing_subnet.id
}

output "security_group_id" {
  description = "Security Group ID to be imported"
  value       = aws_security_group.existing_sg.id
}

output "instance_id" {
  description = "Instance ID to be imported"
  value       = aws_instance.existing_instance.id
}

output "bucket_name" {
  description = "S3 Bucket name to be imported"
  value       = aws_s3_bucket.existing_bucket.bucket
}

output "import_commands" {
  description = "Commands to import these resources"
  value = {
    vpc            = "terraform import aws_vpc.imported_vpc ${aws_vpc.existing_vpc.id}"
    subnet         = "terraform import aws_subnet.imported_subnet ${aws_subnet.existing_subnet.id}"
    security_group = "terraform import aws_security_group.imported_sg ${aws_security_group.existing_sg.id}"
    instance       = "terraform import aws_instance.imported_instance ${aws_instance.existing_instance.id}"
    bucket         = "terraform import aws_s3_bucket.imported_bucket ${aws_s3_bucket.existing_bucket.bucket}"
  }
}