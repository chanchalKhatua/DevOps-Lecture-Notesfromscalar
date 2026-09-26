# Part 2: Remote State Backends (35 minutes)

## 🏗️ Backend Types and Selection (15 minutes)

### Why Remote Backends?

**The Problem with Local State:**
```bash
# Team member A
terraform apply  # Creates infrastructure

# Team member B (different machine)
terraform apply  # No knowledge of existing infrastructure!
```

**Remote Backend Solutions:**
- Centralized state storage
- Team collaboration
- State locking
- Encryption and security
- Versioning and backup

### Backend Selection Matrix

| Scenario | Recommended Backend | Reasoning |
|----------|-------------------|-----------|
| AWS Production | S3 + DynamoDB | Native integration, encryption, locking |
| Azure Production | Azure RM | Native integration, built-in locking |
| GCP Production | GCS | Native integration, good performance |
| Multi-cloud | Consul | Cloud-agnostic, distributed |
| Enterprise | Terraform Cloud | Advanced features, policy enforcement |
| Development | Local | Simple, fast iteration |

### S3 Backend Deep Dive

**Configuration:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    
    # Optional: Advanced settings
    versioning     = true
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
}
```

**S3 Backend Features:**
- **Encryption**: Server-side encryption (SSE-S3, SSE-KMS)
- **Versioning**: State file history
- **Access Control**: IAM policies
- **Cross-region replication**: Disaster recovery
- **Lifecycle policies**: Cost optimization

### State Locking Mechanisms

**Why Locking is Critical:**
```bash
# Without locking - DISASTER SCENARIO
User A: terraform apply  # Starts at 10:00:00
User B: terraform apply  # Starts at 10:00:05
# Both read same state, both make changes
# Result: Corrupted infrastructure!
```

**DynamoDB Locking Table:**
```hcl
resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}
```

**Lock Information:**
- **LockID**: Unique identifier for the lock
- **Operation**: Type of operation (plan, apply)
- **Info**: User, timestamp, operation details
- **Who**: User information
- **Version**: Terraform version
- **Created**: Lock creation timestamp

---

## 🛠️ Demo 2: S3 Backend Setup (10 minutes)

### Interactive Exercise: Migrating to S3 Backend

**Learning Goals:**
- Set up S3 backend infrastructure
- Migrate from local to remote state
- Understand backend configuration
- Practice state migration

**What We'll Build:**
- S3 bucket with encryption
- DynamoDB table for locking
- Migrate existing state
- Test collaborative workflow

**Migration Process:**
1. Create backend infrastructure
2. Configure backend in Terraform
3. Initialize backend migration
4. Verify state migration
5. Test locking mechanism

---

## 🔒 Demo 3: State Locking with DynamoDB (10 minutes)

### Interactive Exercise: Understanding State Locking

**Learning Goals:**
- See locking in action
- Understand lock conflicts
- Practice lock troubleshooting
- Learn force-unlock procedures

**Scenarios We'll Test:**
1. Normal locking behavior
2. Lock conflict simulation
3. Abandoned lock cleanup
4. Force unlock procedures

**Key Commands:**
```bash
terraform force-unlock <lock-id>  # Emergency unlock
terraform apply -lock=false      # Disable locking (dangerous!)
terraform plan -lock-timeout=10s # Custom lock timeout
```

---

## 🔐 Backend Security Best Practices

### S3 Bucket Security
```hcl
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform_state.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### IAM Policies for State Access
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketVersioning"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state-bucket"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::my-terraform-state-bucket/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
    }
  ]
}
```

### Backend Configuration Patterns

**Environment-Specific Backends:**
```hcl
# Development
terraform {
  backend "s3" {
    bucket = "mycompany-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "us-west-2"
  }
}

# Production
terraform {
  backend "s3" {
    bucket = "mycompany-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-west-2"
  }
}
```

**Project-Based Organization:**
```
s3://mycompany-terraform-state/
├── networking/
│   ├── dev/terraform.tfstate
│   ├── staging/terraform.tfstate
│   └── prod/terraform.tfstate
├── applications/
│   ├── web-app/
│   │   ├── dev/terraform.tfstate
│   │   └── prod/terraform.tfstate
│   └── api/
│       ├── dev/terraform.tfstate
│       └── prod/terraform.tfstate
└── security/
    ├── dev/terraform.tfstate
    └── prod/terraform.tfstate
```