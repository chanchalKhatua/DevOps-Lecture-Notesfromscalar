variable "ProjectName" {
    description = "Enter the Project name"
    type = string
}

variable "Environment" {
    description = "Enter the Environment name"
    type = string
    default = "Prod"
}

variable "VpcId" {
    description =   "Enter the VPC ID"
    type    =   string
}