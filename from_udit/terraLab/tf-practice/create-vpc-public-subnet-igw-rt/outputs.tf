output "vpc_id" {
  description = "The ID of the AWS VPC"
  value = aws_vpc.main_vpc.id
}

output "subnet_id" {
  description = "The ID of the AWS Subnet"
  value = aws_subnet.main_subnet.id
}

output "igw_id" {
  description = "The ID of the AWS Internet Gateway"
  value = aws_internet_gateway.main_igw.id
}