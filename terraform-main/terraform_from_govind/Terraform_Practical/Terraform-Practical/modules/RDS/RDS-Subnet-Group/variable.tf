variable "ProjectName" {
  description = "Enter the Project name"
  type        = string
}

variable "Environment" {
  description = "Enter the Environment name"
  type        = string
  default     = "Prod"
}

variable "DBSubnets" {
  description = "Enter the list of DB Subnets. The subnets should be in different Availability Zone. (If PubliclyAccessible=true then provide public subnets else provide private subnets)"
  type        = list(string)
}

variable "SubnetGroupName" {
  description = "Enter the Subnet Group Name. (Only lower case alphanumeric characters and hypens are allowed)"
  type        = string
}