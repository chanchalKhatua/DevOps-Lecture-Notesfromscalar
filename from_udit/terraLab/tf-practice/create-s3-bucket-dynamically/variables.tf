variable "buckets" {
    description = "List of S3 bucket names"
    type        = map(string)
    default = {
        bucket_01 = "lab-bucket-one"
        bucket_01_description = "This is the first lab bucket"
        bucket_02 = "lab-bucket-two"
        bucket_02_description = "This is the second lab bucket"
      }
}