provider "aws" {
  region = "us-west-2"
  
}

resource "aws_instance" "app" {

  ami = var.ami_id
  count = var.instance_count
  instance_type = "t3.micro"

  tags = {
    Name = "dynamic-instance-${count.index}" # Use count.index to differentiate instance names
  }
}
