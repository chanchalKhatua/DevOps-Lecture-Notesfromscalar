resource "aws_iam_role" "EKSClusterRole" {
  name = "${var.ProjectName}-${var.Environment}-Role"
  tags = {
    "Name" = "${var.ProjectName}-${var.Environment}-EKSClusterRole"
    "Environment"="${var.Environment}"
  }
  assume_role_policy = jsonencode({
    "Statement" = [
      {
        "Action"    = "sts:AssumeRole",
        "Effect"    = "Allow",
        "Principal" = { "Service" = "eks.amazonaws.com" }
      }
    ]
  })
  path = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]
}