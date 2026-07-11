terraform {
  source = "../../modules/base"
}

inputs = {
  region        = "us-west-2"
  bucket_name   = "terragrunt-lab-bucket-"
  instance_type = "t3.micro"
}