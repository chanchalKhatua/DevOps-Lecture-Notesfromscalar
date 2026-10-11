terraform {
  backend "s3" {
    bucket = "chrishel-terraform-s3-private"
    key = "RDS-Instance-jenkins/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "chrishel-terraform-dynamo-db"
  }
}