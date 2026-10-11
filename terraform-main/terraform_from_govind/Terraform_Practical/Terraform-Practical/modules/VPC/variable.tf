variable "Region" {
    description = "Select the region"
    type = string
    default = "ap-south-1"
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

variable "WantDataBaseTier" {
    description = "Want Database or Not? Please pass yes/no"
    type = string
    default = "yes"
    validation {
      condition     = var.WantDataBaseTier == "yes" || var.WantDataBaseTier == "no"
      error_message = "Please enter yes or no"
    }
}

variable "AvailabilityZones" {
    description = "List of Availability Zones to use for the subnets in the VPC"
    type = list(string)
    default     = ["ap-south-1a","ap-south-1b","ap-south-1c"]
}

variable "NumberOfAZs" {
    description = "Number of Availability Zones to use in the VPC. This must match your selections in the list of Availability Zones parameter."
    type = number
    default = 3
    validation {
      condition = var.NumberOfAZs >= 2 && var.NumberOfAZs <= 6
      error_message = "Number of AZs must be in the range of 2 to 6"
    }
}

variable "VpcCidr" {
    description = "CIDR block for the VPC. Note:CIDR block parameter must be in the form x.x.x.x/16-28"
    type = string
    default = "10.0.0.0/16"
}

variable "VpcTenancy" {
    description = "The allowed tenancy of instances launched into the VPC"
    type = string
    default = "default"
    validation {
      condition = var.VpcTenancy == "default" || var.VpcTenancy == "dedicated"
      error_message = "Please enter default or dedicated as input"
    }
}

variable "WantNatGatewayForPrivateSubnets" {
    description = "Want NatGateway for Private Subnet or Not? If Yes, Select Yes"
    type = string
    default = "yes"
    validation {
      condition = var.WantNatGatewayForPrivateSubnets == "yes" || var.WantNatGatewayForPrivateSubnets == "no"
      error_message = "Please enter yes or no"
    }
}

variable "NumberOfNATs" {
    description = "Enter the number of NAT gateways needed. NOTE: Accepted values single or multiple(Number of nat gateway = number of availability zones)"
    type = string
    default = "single"
    validation {
      condition = var.NumberOfNATs == "single" || var.NumberOfNATs == "multiple"
      error_message = "Accepted values are single or multiple"
    }
}

variable "WantNatGatewayForDataBaseSubnets" {
    description = "Want NatGateway for Database Subnet or Not? If Yes, Select Yes"
    type = string
    default = "yes"
    validation {
      condition = var.WantNatGatewayForDataBaseSubnets == "yes" || var.WantNatGatewayForDataBaseSubnets == "no"
      error_message = "Please enter yes or no"
    } 
}

variable "WantVpcFlowLogs" {
    description = "Want VpcFlowlogs or Not? If Yes, Select enable"
    type = string
    default = "enable"
    validation {
      condition = var.WantVpcFlowLogs=="disable" || var.WantVpcFlowLogs=="enable"
      error_message = "Please enter disable or enable"
    }
}

variable "DataSubnetCidr" {
    description = "CIDR blocks for data subnets located in the selected Availability Zones"
    type = map(list(string))
    default = {
        2 = ["10.0.100.0/24", "10.0.101.0/24"]
        3 = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
        4 = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
        5 = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24", "10.0.104.0/24"]
        6 = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24", "10.0.104.0/24", "10.0.105.0/24"]
    }
}

variable "PublicSubnetCidr" {
    description = "CIDR block for Public subnets located in the selected Availability Zones"
    type = map(list(string))
    default = {
        2 = ["10.0.200.0/24", "10.0.201.0/24" ]
        3 = ["10.0.200.0/24", "10.0.201.0/24", "10.0.202.0/24"]
        4 = ["10.0.200.0/24", "10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
        5 = ["10.0.200.0/24", "10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24", "10.0.204.0/24"],
        6 = ["10.0.200.0/24", "10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24", "10.0.204.0/24", "10.0.205.0/24"]
        }
}

variable "PrivateSubnetCidr" {
    description = "CIDR block for Private subnets located in the selected Availability Zones"
    type = map(list(string))
    default = {
       2 = ["10.0.0.0/22", "10.0.4.0/22"]
       3 = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
       4 = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22", "10.0.12.0/22"]
       5 = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22", "10.0.12.0/22", "10.0.16.0/22"]
       6 = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22", "10.0.12.0/22", "10.0.16.0/22", "10.0.20.0/22"]
    }
}