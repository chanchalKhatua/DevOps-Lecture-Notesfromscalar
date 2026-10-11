resource "aws_db_subnet_group" "PrivateDbSubnetGroup" {
  description = "Subnets for RDS"
  name        = var.SubnetGroupName
  subnet_ids  = var.DBSubnets
  tags = {
    Name = "${var.ProjectName}-${var.Environment}-DbSubnetGroup"
    Environment = var.Environment
  }
}
