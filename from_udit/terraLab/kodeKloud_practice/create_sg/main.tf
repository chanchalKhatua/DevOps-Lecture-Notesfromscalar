resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "nautilus-sg" {
  name        = "devops-sg"
  description = "Security group for Nautilus App Servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "devops-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_http" {
    security_group_id = aws_security_group.nautilus-sg.id
    from_port = 80
    ip_protocol = "tcp"
    to_port = 80
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_ssh" {
    security_group_id = aws_security_group.nautilus-sg.id
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22
    cidr_ipv4 = "0.0.0.0/0"
}