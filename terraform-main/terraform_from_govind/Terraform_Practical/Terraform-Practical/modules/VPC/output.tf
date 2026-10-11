output "Vpc_Id" {
  description = "Vpc Id"
  value = aws_vpc.Vpc.id
}

output "Public_Subnet_Ids" {
  description = "Public Subnet Ids"
  value = [for subnet in aws_subnet.PublicSubnet : subnet.id]
}

output "Private_Subnet_Ids" {
  description = "Private Subnet Ids"
  value = [for subnet in aws_subnet.PrivateSubnet : subnet.id]
}

output "Database_Subnet_Ids" {
  description = "Database Subnet Ids"
  value = [for subnet in aws_subnet.DatabaseSubnet : subnet.id]
}