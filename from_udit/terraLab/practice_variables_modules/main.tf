provider "aws" {
    region = "us-east-1"
  
}

module "aws_instance" {
    source = "./modules/ec2_instance"
    amazon_ami_value = "ami-0614680123427b75e"
    ubuntu_ami_value = "ami-0dee22c13ea7a9a67"
    instance_type_value = "t2.micro"
  
}