provider "aws" {
    region ="ap-south-1"
  
}

resource "aws_instance" "ubuntu-instance" {
    ami = var.ubuntu_ami_value
    instance_type = var.instance_type_value
  
}

resource "aws_instance" "amazon-instance" {
    ami = var.amazon_ami_value
    instance_type = var.instance_type_value
  
}

