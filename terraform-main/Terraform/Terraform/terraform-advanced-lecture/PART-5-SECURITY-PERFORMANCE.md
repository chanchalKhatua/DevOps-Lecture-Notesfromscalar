# Part 5: Security and Performance Optimization (20 minutes)

## 🔐 State Encryption and Security (10 minutes)

### State File Security Concerns

Terraform state files contain sensitive information:
- Resource IDs and configurations
- Database passwords and connection strings
- API keys and certificates
- Network topology and security group rules
- Private IP addresses and internal configurations

### Encryption at Rest

#### S3 Backend Encryption
```hcl
terraform {
  backend "s3" {
    bucket     = "my-terraform-state"
    key        = "prod/terraform.tfstate"
    region     = "us-west-2"
    encrypt    = true
    kms_key_id = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}
```

#### KMS Key Management
```hcl
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 7
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Terraform State Access"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/terraform-execution-role"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### Access Control and IAM

#### Principle of Least Privilege
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::terraform-state-bucket/team-a/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-west-2:123456789012:table/terraform-locks",
      "Condition": {
        "StringEquals": {
          "dynamodb:LeadingKeys": ["team-a"]
        }
      }
    }
  ]
}
```

#### Cross-Account State Access
```hcl
# Cross-account bucket policy
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::111111111111:role/terraform-dev-role",
            "arn:aws:iam::222222222222:role/terraform-prod-role"
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.terraform_state.arn}/*"
      }
    ]
  })
}
```

### Sensitive Data Management

#### Using Sensitive Variables
```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# Sensitive outputs
output "database_connection" {
  value = {
    host     = aws_db_instance.main.endpoint
    username = aws_db_instance.main.username
    password = aws_db_instance.main.password
  }
  sensitive = true
}
```

#### External Secret Management
```hcl
# Using AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
}

resource "aws_db_instance" "main" {
  password = local.db_password
  # other configuration
}
```

#### HashiCorp Vault Integration
```hcl
# Using Vault provider
provider "vault" {
  address = "https://vault.company.com"
}

data "vault_generic_secret" "database" {
  path = "secret/database"
}

resource "aws_db_instance" "main" {
  password = data.vault_generic_secret.database.data["password"]
  # other configuration
}
```

### State File Auditing

#### S3 Access Logging
```hcl
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "terraform-state-access/"
}

resource "aws_s3_bucket" "access_logs" {
  bucket = "terraform-state-access-logs-${random_id.suffix.hex}"
}
```

#### CloudTrail Integration
```hcl
resource "aws_cloudtrail" "terraform_state" {
  name           = "terraform-state-trail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.bucket

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    exclude_management_event_sources = []

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.terraform_state.arn}/*"]
    }
  }
}
```

---

## ⚡ Performance Optimization (10 minutes)

### State File Size Optimization

#### Large State File Issues
- Slow terraform plan/apply operations
- Increased memory usage
- Network transfer delays
- Higher risk of corruption

#### State Splitting Strategies
```bash
# Split by environment
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "environments/${terraform.workspace}/terraform.tfstate"
  }
}

# Split by service
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "services/networking/terraform.tfstate"
  }
}

# Split by team
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "teams/platform/terraform.tfstate"
  }
}
```

#### Resource Organization
```hcl
# Instead of managing everything in one configuration
# Split into logical modules

# networking/main.tf
module "vpc" {
  source = "./modules/vpc"
}

# applications/main.tf
module "web_app" {
  source = "./modules/web-app"
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id
}

# security/main.tf
module "security_groups" {
  source = "./modules/security"
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id
}
```

### Parallel Execution Optimization

#### Resource Dependencies
```hcl
# Explicit dependencies for better parallelization
resource "aws_security_group" "web" {
  # configuration
}

resource "aws_security_group" "db" {
  # configuration
}

# These can be created in parallel
resource "aws_instance" "web" {
  depends_on = [aws_security_group.web]
  # configuration
}

resource "aws_db_instance" "main" {
  depends_on = [aws_security_group.db]
  # configuration
}
```

#### Parallelism Configuration
```bash
# Increase parallelism for faster operations
terraform apply -parallelism=20

# Set in environment variable
export TF_CLI_ARGS_apply="-parallelism=20"
export TF_CLI_ARGS_plan="-parallelism=20"
```

### Provider Optimization

#### Provider Caching
```bash
# Enable provider caching
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
mkdir -p $TF_PLUGIN_CACHE_DIR

# Use shared provider cache across projects
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

#### Multiple Provider Instances
```hcl
# Use multiple provider instances for different regions
provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}

provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

# Resources in different regions can be managed in parallel
resource "aws_instance" "west" {
  provider = aws.us_west
  # configuration
}

resource "aws_instance" "east" {
  provider = aws.us_east
  # configuration
}
```

### Network and API Optimization

#### Retry Configuration
```hcl
provider "aws" {
  region = "us-west-2"
  
  retry_mode      = "adaptive"
  max_retries     = 10
  
  # Custom retry configuration
  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}
```

#### Request Batching
```hcl
# Use data sources efficiently
data "aws_instances" "web_servers" {
  filter {
    name   = "tag:Environment"
    values = ["production"]
  }
}

# Instead of multiple individual data sources
# data "aws_instance" "web1" { ... }
# data "aws_instance" "web2" { ... }
```

### Memory and CPU Optimization

#### Resource Targeting
```bash
# Target specific resources for faster operations
terraform apply -target=aws_instance.web
terraform plan -target=module.networking

# Refresh only specific resources
terraform refresh -target=aws_instance.web
```

#### State Operations Optimization
```bash
# Use state operations for bulk changes
terraform state mv 'aws_instance.web[0]' 'aws_instance.web_server[0]'
terraform state mv 'aws_instance.web[1]' 'aws_instance.web_server[1]'

# Instead of recreating resources
```

### Monitoring and Metrics

#### Performance Monitoring
```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Time operations
time terraform plan
time terraform apply

# Monitor resource usage
top -p $(pgrep terraform)
```

#### State File Metrics
```bash
# Monitor state file size
ls -lh terraform.tfstate

# Count resources
terraform state list | wc -l

# Analyze state file structure
terraform show -json | jq '.values.root_module.resources | length'
```

### Best Practices Summary

#### State Management
- Keep state files small and focused
- Use remote backends with encryption
- Implement proper access controls
- Regular state file backups
- Monitor state file size and complexity

#### Performance
- Optimize resource dependencies
- Use appropriate parallelism settings
- Cache providers when possible
- Target specific resources when needed
- Split large configurations into modules

#### Security
- Encrypt state at rest and in transit
- Use IAM roles with least privilege
- Implement audit logging
- Manage secrets externally
- Regular security reviews

#### Operational
- Automate state operations
- Implement CI/CD pipelines
- Use workspace strategies appropriately
- Monitor and alert on state changes
- Document state management procedures