variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "security_group_name" {
  description = "Name of the security group to import"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket to import"
  type        = string
}