output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.compute.alb_dns_name}"
}

output "bastion_ip" {
  description = "Public IP of the bastion host"
  value       = module.compute.bastion_public_ip
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.s3_bucket_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "environment_info" {
  description = "Environment information"
  value = {
    project_name = "webapp"
    environment  = "dev"
    region      = var.aws_region
    vpc_cidr    = module.vpc.vpc_cidr_block
  }
}