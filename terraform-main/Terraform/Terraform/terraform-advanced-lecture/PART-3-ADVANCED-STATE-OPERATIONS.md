# Part 3: Advanced State Operations (40 minutes)

## 🛠️ State Commands Mastery (15 minutes)

### The Terraform State Command Arsenal

Terraform provides powerful commands for state manipulation. Understanding these is crucial for advanced state management.

### Core State Commands

#### 1. terraform state list
```bash
# List all resources
terraform state list

# Filter by resource type
terraform state list | grep aws_instance

# Show resources with specific pattern
terraform state list 'aws_instance.*'
```

#### 2. terraform state show
```bash
# Show specific resource details
terraform state show aws_instance.web_server

# Show in JSON format
terraform state show -json aws_instance.web_server
```

#### 3. terraform state mv
```bash
# Rename a resource
terraform state mv aws_instance.old_name aws_instance.new_name

# Move resource to module
terraform state mv aws_instance.web_server module.web.aws_instance.server

# Move entire module
terraform state mv module.old_module module.new_module
```

#### 4. terraform state rm
```bash
# Remove resource from state (keeps real resource)
terraform state rm aws_instance.web_server

# Remove multiple resources
terraform state rm aws_instance.web1 aws_instance.web2

# Remove entire module
terraform state rm module.web_servers
```

#### 5. terraform state pull/push
```bash
# Download current state
terraform state pull > current-state.json

# Upload modified state (DANGEROUS!)
terraform state push modified-state.json
```

### Advanced State Manipulation Scenarios

#### Scenario 1: Resource Refactoring
```hcl
# Before: Single resource
resource "aws_instance" "web_server" {
  # configuration
}

# After: Module-based
module "web_servers" {
  source = "./modules/web-server"
  # configuration
}
```

**Migration Commands:**
```bash
terraform state mv aws_instance.web_server module.web_servers.aws_instance.server
```

#### Scenario 2: Resource Splitting
```hcl
# Before: One large resource
resource "aws_security_group" "web_sg" {
  # many rules
}

# After: Separate rule resources
resource "aws_security_group" "web_sg" {
  # base configuration
}

resource "aws_security_group_rule" "http_ingress" {
  # specific rule
}
```

#### Scenario 3: Environment Separation
```bash
# Move resources between environments
terraform state mv aws_instance.shared_resource module.production.aws_instance.shared_resource
```

---

## 📥 Import Operations Deep Dive

### Understanding terraform import

Import allows you to bring existing infrastructure under Terraform management.

#### Basic Import Syntax
```bash
terraform import <resource_address> <resource_id>
```

#### Common Import Scenarios

**AWS Resources:**
```bash
# Import EC2 instance
terraform import aws_instance.web i-1234567890abcdef0

# Import VPC
terraform import aws_vpc.main vpc-12345678

# Import S3 bucket
terraform import aws_s3_bucket.data my-existing-bucket

# Import RDS instance
terraform import aws_db_instance.main mydb-instance
```

**Complex Resources:**
```bash
# Import security group rule
terraform import aws_security_group_rule.web_http sg-12345678_ingress_tcp_80_80_0.0.0.0/0

# Import route table association
terraform import aws_route_table_association.public subnet-12345678/rtb-87654321
```

### Import Best Practices

#### 1. Pre-Import Preparation
```bash
# 1. Write the resource configuration first
resource "aws_instance" "imported_server" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  # ... other required attributes
}

# 2. Run terraform plan to see what would be created
terraform plan

# 3. Import the existing resource
terraform import aws_instance.imported_server i-1234567890abcdef0

# 4. Run plan again to see differences
terraform plan
```

#### 2. Handling Import Differences
```bash
# After import, you might see differences
terraform plan

# Common issues:
# - Missing optional attributes
# - Default values vs actual values
# - Computed attributes
```

#### 3. Bulk Import Strategies
```bash
# Create import script for multiple resources
cat > import-script.sh << 'EOF'
#!/bin/bash
terraform import aws_instance.web1 i-1111111111111111
terraform import aws_instance.web2 i-2222222222222222
terraform import aws_instance.web3 i-3333333333333333
EOF

chmod +x import-script.sh
./import-script.sh
```

---

## 🔄 State Migration Strategies

### Migration Scenarios

#### 1. Backend Migration
```bash
# From local to S3
terraform init  # Will prompt for migration

# From S3 to different S3 bucket
terraform init -reconfigure
```

#### 2. State File Splitting
```bash
# Split monolithic state into multiple states
terraform state mv module.networking ../networking-state/
terraform state mv module.applications ../app-state/
```

#### 3. State File Merging
```bash
# Pull states from different backends
terraform state pull > state1.json
cd ../other-project
terraform state pull > state2.json

# Merge states (requires careful planning)
# This is complex and requires manual JSON manipulation
```

### Migration Tools and Techniques

#### Using terraformer for Bulk Import
```bash
# Install terraformer
go install github.com/GoogleCloudPlatform/terraformer/cmd/terraformer@latest

# Import all AWS resources in a region
terraformer import aws --resources=ec2_instance,vpc,subnet --regions=us-west-2
```

#### Custom Import Scripts
```python
#!/usr/bin/env python3
import boto3
import subprocess
import json

def import_ec2_instances():
    ec2 = boto3.client('ec2')
    instances = ec2.describe_instances()
    
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            name_tag = next((tag['Value'] for tag in instance.get('Tags', []) 
                           if tag['Key'] == 'Name'), instance_id)
            
            resource_name = f"aws_instance.{name_tag.replace('-', '_')}"
            
            cmd = f"terraform import {resource_name} {instance_id}"
            print(f"Importing: {cmd}")
            subprocess.run(cmd, shell=True)

if __name__ == "__main__":
    import_ec2_instances()
```

---

## 🚨 State Troubleshooting

### Common State Issues

#### 1. State Drift
```bash
# Detect drift
terraform plan

# Refresh state from real infrastructure
terraform refresh

# Show differences
terraform show
```

#### 2. Corrupted State
```bash
# Backup current state
terraform state pull > backup-state.json

# Restore from backup
terraform state push backup-state.json

# Or restore from S3 version
aws s3api get-object --bucket my-state-bucket --key terraform.tfstate --version-id <version> restored-state.json
terraform state push restored-state.json
```

#### 3. Missing Resources
```bash
# Resource exists in state but not in cloud
terraform plan  # Will show resource to be created

# Remove from state if resource is truly gone
terraform state rm aws_instance.missing_server

# Or import if resource exists with different ID
terraform import aws_instance.missing_server i-newinstanceid
```

#### 4. Duplicate Resources
```bash
# Multiple state files managing same resource
# Solution: Remove from one state
terraform state rm aws_instance.duplicate_resource
```

### State Recovery Procedures

#### Emergency State Recovery
```bash
# 1. Stop all Terraform operations
# 2. Backup current state
terraform state pull > emergency-backup.json

# 3. Identify the issue
terraform plan -detailed-exitcode

# 4. Fix the state
# Option A: Manual JSON editing (dangerous)
# Option B: Use state commands
# Option C: Restore from backup

# 5. Verify fix
terraform plan
```

#### State Validation
```bash
# Validate state consistency
terraform validate
terraform plan -detailed-exitcode

# Check for orphaned resources
# Compare terraform state list with actual cloud resources
```

---

## 🎯 Demo 4 & 5 Preview

### Demo 4: State Import/Export (10 minutes)
- Import existing AWS resources
- Handle import conflicts
- Bulk import strategies
- State export techniques

### Demo 5: State Migration (15 minutes)
- Backend migration scenarios
- State file splitting
- Cross-environment migration
- Recovery procedures

**Key Learning Outcomes:**
- Master state manipulation commands
- Understand import/export workflows
- Practice migration scenarios
- Learn troubleshooting techniques