resource "aws_security_group" "RDS-Cluster-SG" {
  description = "Security Group for RDS Cluster"
  name = "${var.ProjectName}-${var.Environment}-RDS-SecurityGroup"
  vpc_id = var.VpcId
  tags = {
    "Name"="${var.ProjectName}-${var.Environment}-RDS-Cluster-SecurityGroup"
    "Environment"="${var.Environment}"
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow all Inbound traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.CidrIp]
  }
}
