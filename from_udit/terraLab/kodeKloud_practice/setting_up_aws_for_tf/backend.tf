terraform {
    backend "s3" {
      bucket = "my-terraform-state-13022026"
      key            = "terraform-state-file"
      region         = "us-east-1"
      encrypt        = true
    }
    
}