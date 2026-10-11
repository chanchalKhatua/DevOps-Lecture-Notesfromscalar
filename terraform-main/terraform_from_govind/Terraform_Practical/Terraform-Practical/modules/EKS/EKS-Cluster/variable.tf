
variable "ProjectName" {
    description = "Enter the Project name"
    type = string
}

variable "Environment" {
    description = "Enter the Environment name"
    type = string
    default = "Prod"
}

variable "PrivateSubnetID" {
    description = "List of private Subnet ids"
    type = list(string)
}

variable "ClusterSecurityGroup" {
    description = "Enter the EKS Cluster Security group"
    type = string
}

variable "EKSVersion" {
    description = "Enter the EKS version"
    type = string
    default = "1.27"
}

variable "KubeAPIEndpoint" {
    description = "Do you want your Kubernetes API server endpoint to be publicly accessible?"
    type = bool
    default = false
    validation {
      condition = var.KubeAPIEndpoint==true||var.KubeAPIEndpoint==false
      error_message = "Please enter boolean true/false"
    }
}

variable "ControlPlaneLogs" {
    description = "Send audit and diagnostic logs from the Amazon EKS control plane to CloudWatch Logs."
    type = bool
    default = false
    validation {
      condition = var.ControlPlaneLogs==true||var.ControlPlaneLogs==false
      error_message = "Please enter boolean true/false"
    }
}

variable "EKSClusterRoleARN" {
    description =   "Enter the EKS Cluster IAM Role ARN"
    type    =   string
}
