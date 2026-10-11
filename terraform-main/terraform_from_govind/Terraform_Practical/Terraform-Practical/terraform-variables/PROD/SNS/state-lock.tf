terraform {
  backend "s3" {
  bucket = "testterraformjenkinss3pramod"
  key = "SNS-Testing/terraform.tfstate"
  region = "ap-south-1"
  dynamodb_table = "testterraformjenkinsdynamopramod"
  }
}