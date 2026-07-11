provider "aws" {
  region = "us-west-2"
}

resource "aws_iam_role" "ec2_s3_readonly_role" {
  name = "ec2_s3_readonly_role"

  assume_role_policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.ec2_s3_readonly_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}