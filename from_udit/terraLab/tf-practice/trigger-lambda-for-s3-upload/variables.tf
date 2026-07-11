variable "bucket_name" {
    description = "The name of the S3 bucket"
    type        = string
}

variable "lambda_function_name" {
    description = "Name of the lambda function"
    default = "hello_lambda"
}