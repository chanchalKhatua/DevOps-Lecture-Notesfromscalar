variable "Region" {
    description = "Enter the AWS Region"
    type = string
    default =   "ap-south-1"
}

variable "ProjectName" {
    description = "Enter the Project name"
    type = string
}

variable "Environment" {
    description = "Enter the Environment name"
    type = string
    default = "Prod"
}

variable "ClusterName" {
    description = "The cluster name provided when the cluster was created. If it is incorrect, nodes will not be able to join the cluster."
    type = string
}

variable "NodeInstanceRole" {
    description = "The IAM Role ARN for the EKS Nodegroup Instances."
    type = string
}

variable "NodeImageIdSSMParam" {
    description = "AWS Systems Manager Parameter Store parameter of the AMI ID for the worker node instances."
    type = string
    default = "/aws/service/eks/optimized-ami/1.27/amazon-linux-2/recommended/image_id"
}   

variable "NodeInstanceType" {
    description = "EC2 instance type for the node instances(Must be a valid EC2 instance type)"
    type = string
    default = "c5a.large"
}

variable "PrivateSubnetID" {
    description = "Enter a list of Private Subnet Ids"
    type = list(string)
}

variable "AMIArchitectureForNodeGroup" {
    description = "The Architecture on which the Nodes will run, For Custom Node Group please leave this as Custom."
    type = string
    default = "CUSTOM"
    validation {
      condition = var.AMIArchitectureForNodeGroup =="AL2_ARM_64"||var.AMIArchitectureForNodeGroup =="AL2_x86_64"||var.AMIArchitectureForNodeGroup =="AL2_x86_64_GPU"||var.AMIArchitectureForNodeGroup =="BOTTLEROCKET_ARM_64"||var.AMIArchitectureForNodeGroup =="BOTTLEROCKET_x86_64"||var.AMIArchitectureForNodeGroup =="CUSTOM"
      error_message = "Allowed values are : AL2_ARM_64, AL2_x86_64, AL2_x86_64_GPU, BOTTLEROCKET_ARM_64, BOTTLEROCKET_x86_64 and CUSTOM"
    }
}

variable "ClusterType" {
    description = "The Cluster Purchasing options."
    type = string
    default = "ON_DEMAND"
    validation {
      condition = var.ClusterType=="ON_DEMAND"||var.ClusterType=="SPOT"
      error_message = "Please enter ON_DEMAND or SPOT"
    }
}

variable "BootstrapArgumentsForOnDemand" {
    description = "Arguments to pass to the bootstrap script. See files/bootstrap.sh in https://github.com/awslabs/amazon-eks-ami"
    type = string
    default = "--kubelet-extra-args --node-labels=lifecycle=OnDemand"
}

variable "BootstrapArgumentsForSpotFleet" {
    description = "Arguments to pass to the bootstrap script. See files/bootstrap.sh in https://github.com/awslabs/amazon-eks-ami"
    type = string
    default = "--kubelet-extra-args ''--node-labels=lifecycle=Ec2Spot --register-with-taints=spotInstance=true:PreferNoSchedule''"
}

variable "DiskSize" {
    description = "The Disk Size for EKS Node."
    type = number
    default = 50
}

variable "KeyName" {
    description = "EC2 keypair for Nodegroup login."
    type = string
}

variable "ManagedNodeDesiredInstanceCount" {
    description = "The Desired Instance in Managed EKS ASG. Please leave it blank if you are going with Launch Template or Custom AMI."
    type = number
    default = 2
}

variable "ManagedNodeMinInstanceCount" {
    description = "The Minimum Instance in Managed EKS ASG. Please leave it blank if you are going with Launch Template or Custom AMI."
    type = number
    default = 2
}

variable "ManagedNodeMaxInstanceCount" {
    description = "The Desired Instance in Managed EKS ASG. Please leave it blank if you are going with Launch Template or Custom AMI."
    type = number
    default = 10
}

variable "WorkerNodesSecurityGroup" {
    description = "The Node Security Group."
    type = string
}

variable "NodeGroupName" {
    description = "Unique identifier for the Node Group."
    type = string
}