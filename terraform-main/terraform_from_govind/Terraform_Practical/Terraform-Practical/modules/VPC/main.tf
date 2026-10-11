resource "aws_vpc" "Vpc" {
  cidr_block = var.VpcCidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.ProjectName}-${var.Environment}-Vpc"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_iam_role" "VpcFlowLogsRole" {
  count = var.WantVpcFlowLogs == "enable" ? 1:0
  name = "${var.ProjectName}-${var.Environment}-VPC-FlowLog-Role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
  inline_policy {
    name = "${var.ProjectName}-${var.Environment}-VPC-FlowLog-Policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }]
    })
  }
  tags = {
    "Name" = "${var.ProjectName}-${var.Environment}-VPC-FlowLog-Role"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_flow_log" "VpcFlowLog" {
  count = var.WantVpcFlowLogs == "enable" ? 1:0
  traffic_type = "ALL"
  iam_role_arn = aws_iam_role.VpcFlowLogsRole[count.index].arn
  vpc_id = aws_vpc.Vpc.id
  log_group_name = "${var.ProjectName}-${var.Environment}-VPC-FlowLog"
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.Vpc.id
  tags = {
    "Name" = "${var.ProjectName}-${var.Environment}-InternetGateway"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_subnet" "PublicSubnet" {
  count = var.NumberOfAZs
  vpc_id = aws_vpc.Vpc.id
  cidr_block = element(try(var.PublicSubnetCidr[var.NumberOfAZs], "PublicSubnets"),count.index)
  map_public_ip_on_launch = true
  availability_zone = element(var.AvailabilityZones, count.index)
  tags = {
    "Name" = "${var.ProjectName}-${var.Environment}-PublicSubnet-${count.index+1}"
    "SubnetType" = "Public"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.Vpc.id
  tags = {
    "Name" = "${var.ProjectName}-${var.Environment}-PublicRouteTable"
    "Network" = "Public"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_route" "PublicRoute" {
  depends_on = [ aws_internet_gateway.InternetGateway ]
  route_table_id = aws_route_table.PublicRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.InternetGateway.id
}

resource "aws_route_table_association" "PublicRouteTableAssociation" {
  count = var.NumberOfAZs
  subnet_id = aws_subnet.PublicSubnet[count.index].id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_subnet" "PrivateSubnet" {
  count = var.NumberOfAZs
  vpc_id = aws_vpc.Vpc.id
  cidr_block = element(try(var.PrivateSubnetCidr[var.NumberOfAZs], "PrivateSubnets"),count.index)
  map_public_ip_on_launch = false
  availability_zone = element(var.AvailabilityZones, count.index)
  tags = {
    "Name" = "${var.ProjectName}-${var.Environment}-PrivateSubnet-${count.index+1}"
    "SubnetType" = "Private"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_route_table" "PrivateRouteTable" {
  count = var.WantNatGatewayForPrivateSubnets == "no" || (var.WantDataBaseTier=="yes" && var.WantNatGatewayForDataBaseSubnets=="no")? 1:0
  vpc_id = aws_vpc.Vpc.id
  tags = {
    "Name" = "${var.ProjectName}-${var.Environment}-PrivateRouteTable"
    "Network" = "Private"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_eip" "NatEIP" {
  count = var.WantNatGatewayForPrivateSubnets == "yes" || var.WantNatGatewayForDataBaseSubnets=="yes" ? (var.NumberOfNATs == "single" ? 1:var.NumberOfAZs):0
  domain = "vpc"
  tags = {
    "Name"="${var.ProjectName}-${var.Environment}-NatEIP-${count.index+1}"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_nat_gateway" "NatGateway" {
  count = var.WantNatGatewayForPrivateSubnets == "yes" || var.WantNatGatewayForDataBaseSubnets=="yes" ? (var.NumberOfNATs == "single" ? 1:var.NumberOfAZs):0
  depends_on = [ aws_internet_gateway.InternetGateway ]
  allocation_id = aws_eip.NatEIP[count.index].allocation_id
  subnet_id = aws_subnet.PublicSubnet[count.index].id
  tags = {
    "Name"="${var.ProjectName}-${var.Environment}-NatGateway-${count.index+1}"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_route_table" "NatRouteTable" {
  count = var.WantNatGatewayForPrivateSubnets == "yes" || var.WantNatGatewayForDataBaseSubnets=="yes"? (var.NumberOfNATs == "single" ? 1:var.NumberOfAZs):0
  vpc_id = aws_vpc.Vpc.id
  tags = {
    "Name"="${var.ProjectName}-${var.Environment}-NatRouteTable-${count.index+1}"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_route" "NatRoute" {
  count = var.WantNatGatewayForPrivateSubnets == "yes" || var.WantNatGatewayForDataBaseSubnets == "yes"? (var.NumberOfNATs == "single" ? 1:var.NumberOfAZs):0
  route_table_id = aws_route_table.NatRouteTable[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.NatGateway[count.index].id
}

resource "aws_route_table_association" "PrivateRouteTableAssociation" {
  count = var.NumberOfAZs
  subnet_id = aws_subnet.PrivateSubnet[count.index].id
  route_table_id = var.WantNatGatewayForPrivateSubnets == "yes"? aws_route_table.NatRouteTable[count.index % length(aws_route_table.NatRouteTable)].id : aws_route_table.PrivateRouteTable[count.index % length(aws_route_table.PrivateRouteTable)].id
}

resource "aws_subnet" "DatabaseSubnet" {
  count = var.WantDataBaseTier == "yes" ? var.NumberOfAZs:0
  vpc_id = aws_vpc.Vpc.id
  cidr_block = element(try(var.DataSubnetCidr[var.NumberOfAZs], "DataSubnets"),count.index)
  map_public_ip_on_launch = false
  availability_zone = element(var.AvailabilityZones, count.index)
  tags = {
    "Name" = "${var.ProjectName}-${var.Environment}-DataSubnet-${count.index+1}"
    "SubnetType" = "Private"
    Iaac="Terraform"
    Environment = var.Environment
  }
}

resource "aws_route_table_association" "DatabaseRouteTableAssociation" {
  count = var.WantDataBaseTier == "yes" ? var.NumberOfAZs:0
  subnet_id = aws_subnet.DatabaseSubnet[count.index].id
  route_table_id = var.WantNatGatewayForDataBaseSubnets == "yes"? aws_route_table.NatRouteTable[count.index % length(aws_route_table.NatRouteTable)].id : aws_route_table.PrivateRouteTable[count.index % length(aws_route_table.PrivateRouteTable)].id
}
