variable "ProjectName" {
    description = "Enter the Project name"
    type = string
}

variable "Environment" {
    description = "Enter the Environment name"
    type = string
    default = "Prod"
}

variable "CidrIp" {
    description =   "Enter the VPC CIDR Range"
    type    =   string
    default =   "10.0.0.0/16"
}

variable "VpcId" {
    description =   "Enter the VPC ID"
    type    =   string
}