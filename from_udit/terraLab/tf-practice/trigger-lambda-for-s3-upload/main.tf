provider "aws" {
  region = "us-west-2"
}

resource "random_id" "bucket_suffix" {
    byte_length = 4
}

locals {
    bucket_name = "${var.bucket_name}${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket" "bucket" {
    bucket = local.bucket_name
    force_destroy = true

    tags = {
    Name        = local.bucket_name
    Environment = "Dev"
    }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role-attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  code_signing_config_arn = null
}