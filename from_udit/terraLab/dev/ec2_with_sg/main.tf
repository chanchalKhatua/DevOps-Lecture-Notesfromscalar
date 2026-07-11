provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "my_sg" {
    name        = "my_security_group"
    description = "My security group"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "ec2_with_sg" {
    ami           = "ami-02dfbd4ff395f2a1b"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.my_sg.name]

    tags = {
        Name = "ec2-with-sg"
    }
  
}

output "ec_instance_name" {
    description = "The name of the EC2 instance"
    value       = aws_instance.ec2_with_sg.tags["Name"]
  
}

output "ec2_instance_public_ip" {
    description = "The public IP address of the EC2 instance"
    value       = aws_instance.ec2_with_sg.public_ip
  
}