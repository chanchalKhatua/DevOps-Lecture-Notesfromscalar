terraform {
  backend "s3" {
	bucket = "chrishel-terraform-s3-private"
	key = "EKS-Cluster-pipeline-testing/terraform.tfstate"
	region = "ap-south-1"
	dynamodb_table = "chrishel-terraform-dynamo-db"
	}
}