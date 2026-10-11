terraform {
  backend "s3" {
    bucket = "hotelzify-dev-terraform-state-lock-s3"
    key = "Hotelzify-Dev-Terraform-VPC/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "hotelzify-dev-terraform-state-lock-dynamodb"
  }
}