variable "ProjectName" {
    description = "Enter the Project name"
    type = string
}

variable "Environment" {
    description = "Enter the Environment name"
    type = string
    default = "Prod"
}

variable "NodeGroupName" {
    description = "Unique identifier for the Node Group."
    type = string
}