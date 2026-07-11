# Region variable
variable "region" {
  description = "AWS region for EC2 deployment"
  type        = string
  default     = "us-east-1"
}

# Instance type variable
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Instance name variable
variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "terraform-web-server"
}

# Environment variable
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}
