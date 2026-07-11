provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "dev_ec2_1" {
    ami           = "ami-0f559c3642608c138"
    instance_type = "t2.micro"

    tags = {
        Name = "dev-ec2"   }
}

output "ec2_instance_public_ip" {
    description = "The public IP address of the EC2 instance"
    value       = aws_instance.dev_ec2_1.public_ip
  
}