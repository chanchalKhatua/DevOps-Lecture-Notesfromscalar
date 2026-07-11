provider "aws" {
  region = "us-west-2"
}

locals {
  enforced_region = "us-west-2"
}

resource "aws_iam_group" "dev-team" {
  name = "dev-team"
  path = "/users/"
}

output "enforced_region" {
    description = "The region enforced for the resources"
    value       = local.enforced_region
}
