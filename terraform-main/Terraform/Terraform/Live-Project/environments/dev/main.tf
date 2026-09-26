# Development Environment Configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "live-project/dev/terraform.tfstate"
  #   region         = "us-west-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Local values
locals {
  project_name = "webapp"
  environment  = "dev"
  
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
  }

  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name       = local.project_name
  vpc_cidr          = "10.0.0.0/16"
  availability_zones = local.availability_zones
  enable_nat_gateway = true
  enable_vpc_endpoints = true
  common_tags       = local.common_tags
}

# Security Module
module "security" {
  source = "../../modules/security"

  project_name         = local.project_name
  vpc_id              = module.vpc.vpc_id
  s3_bucket_arn       = module.storage.s3_bucket_arn
  allowed_cidr_blocks = ["0.0.0.0/0"] # Restrict this in production
  common_tags         = local.common_tags
}

# Storage Module
module "storage" {
  source = "../../modules/storage"

  project_name           = local.project_name
  environment           = local.environment
  kms_key_id            = module.security.kms_key_id
  enable_cloudfront     = false # Disabled for dev to save costs
  alb_dns_name          = module.compute.alb_dns_name
  waf_web_acl_arn       = module.security.waf_web_acl_arn
  common_tags           = local.common_tags
}

# Database Module
module "database" {
  source = "../../modules/database"

  project_name                = local.project_name
  environment                = local.environment
  database_subnet_ids        = module.vpc.database_subnet_ids
  database_security_group_id = module.security.database_security_group_id
  kms_key_id                 = module.security.kms_key_id
  
  # Development-specific settings
  db_instance_class          = "db.t3.micro"
  allocated_storage          = 20
  max_allocated_storage      = 50
  backup_retention_period    = 1
  multi_az                   = false
  create_read_replica        = false
  performance_insights_enabled = false
  monitoring_interval        = 0
  
  common_tags = local.common_tags
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  project_name               = local.project_name
  environment               = local.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
  private_subnet_ids        = module.vpc.private_subnet_ids
  alb_security_group_id     = module.security.alb_security_group_id
  web_security_group_id     = module.security.web_security_group_id
  bastion_security_group_id = module.security.bastion_security_group_id
  iam_instance_profile_name = module.security.ec2_instance_profile_name
  
  # Development-specific settings
  instance_type     = "t3.micro"
  min_size         = 1
  max_size         = 2
  desired_capacity = 1
  enable_bastion   = true
  key_pair_name    = var.key_pair_name
  
  # Database connection
  s3_bucket_name = module.storage.s3_bucket_name
  db_endpoint    = module.database.db_instance_endpoint
  db_name        = module.database.db_name
  db_username    = module.database.db_username
  db_password    = module.database.db_password
  
  common_tags = local.common_tags
}