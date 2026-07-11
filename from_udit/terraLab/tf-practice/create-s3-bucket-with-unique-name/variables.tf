# Global Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "base_name" {
  description = "name of bucket"
  type        = string
  default = "user-bucket"
}