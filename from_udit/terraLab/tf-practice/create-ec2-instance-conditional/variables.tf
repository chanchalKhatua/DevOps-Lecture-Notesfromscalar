    variable "ami_id" {
      description = "The AMI ID for the EC2 instance."
      type        = string
      default     = "ami-05ee755be0cd7555c" # Example Amazon Linux 2 AMI
    }

    variable "instance_count" {
      description = "Number of EC2 instances to create."
      type        = number
      default     = 2
    }

    variable "env" {
      description = "The deployment environment (e.g., 'dev', 'prod')."
      type        = string
      default     = "dev"

      validation {
        condition     = contains(["dev", "prod"], var.env)
        error_message = "Valid values for 'environment' are 'dev' or 'prod'."
  }
}