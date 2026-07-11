terraform {
  backend "s3" {
    bucket = "terralab-day4-28112024-2239"
    key = "terralab/terraform.tfstate"
    region = "ap-south-1"
    encrypt = true
    
  }
}