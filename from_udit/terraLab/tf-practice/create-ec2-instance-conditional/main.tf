terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "app" {

  ami = var.ami_id
  instance_type = var.env == "prod" ? "t3.micro" : "t2.micro" # This will create 3 instances of this resource
  count = var.instance_count

  tags = {
    Name = "lab-instance-${count.index}" # Use count.index to differentiate instance names
  }
}

