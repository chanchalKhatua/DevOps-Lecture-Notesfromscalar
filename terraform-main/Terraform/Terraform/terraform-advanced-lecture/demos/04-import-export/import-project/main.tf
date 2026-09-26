# Demo 4: Import Project - New Terraform project that will import existing resources

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

# Resource configurations for import
# These match the existing resources but are not yet managed by Terraform

resource "aws_vpc" "imported_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "existing-vpc-for-import"
    Type = "existing"
  }
}

resource "aws_subnet" "imported_subnet" {
  vpc_id            = aws_vpc.imported_vpc.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "existing-subnet-for-import"
    Type = "existing"
  }
}

resource "aws_security_group" "imported_sg" {
  name        = var.security_group_name  # Will be set during import
  vpc_id      = aws_vpc.imported_vpc.id

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

resource "aws_instance" "imported_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.imported_subnet.id
  vpc_security_group_ids = [aws_security_group.imported_sg.id]

  tags = {
    Name = "existing-server-for-import"
    Type = "existing"
  }
}

resource "aws_s3_bucket" "imported_bucket" {
  bucket = var.bucket_name  # Will be set during import

  tags = {
    Name = "existing-bucket-for-import"
    Type = "existing"
  }
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