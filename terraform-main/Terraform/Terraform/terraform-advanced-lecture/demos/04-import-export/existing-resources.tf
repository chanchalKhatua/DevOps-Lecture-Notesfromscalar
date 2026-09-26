# Demo 4: Import/Export - Existing Resources to Import
# This creates "existing" resources that we'll later import into a new Terraform project

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create resources that simulate "existing infrastructure"
# These will be created first, then we'll import them in another project

# VPC - will be imported
resource "aws_vpc" "existing_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "existing-vpc-for-import"
    Type = "existing"
  }
}

# Subnet - will be imported
resource "aws_subnet" "existing_subnet" {
  vpc_id            = aws_vpc.existing_vpc.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "existing-subnet-for-import"
    Type = "existing"
  }
}

# Security Group - will be imported
resource "aws_security_group" "existing_sg" {
  name_prefix = "existing-sg-"
  vpc_id      = aws_vpc.existing_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "existing-security-group"
    Type = "existing"
  }
}

# EC2 Instance - will be imported
resource "aws_instance" "existing_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.existing_subnet.id
  vpc_security_group_ids = [aws_security_group.existing_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Existing Server - To Be Imported</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "existing-server-for-import"
    Type = "existing"
  }
}

# S3 Bucket - will be imported
resource "aws_s3_bucket" "existing_bucket" {
  bucket = "existing-bucket-for-import-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "existing-bucket-for-import"
    Type = "existing"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}