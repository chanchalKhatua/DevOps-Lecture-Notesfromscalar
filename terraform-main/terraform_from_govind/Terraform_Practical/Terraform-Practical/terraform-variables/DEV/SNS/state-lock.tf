terraform {
  backend "s3" {
  bucket = "chrishel-terraform-s3-private"
  key = "SNS-Testing/terraform.tfstate"
  region = "ap-south-1"
  dynamodb_table = "chrishel-terraform-dynamo-db"
  }
}