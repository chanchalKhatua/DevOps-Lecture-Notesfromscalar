# Demo 4: Import/Export Commands

## 🎯 Demo Objectives
- Import existing AWS resources into Terraform
- Handle import conflicts and differences
- Practice bulk import strategies
- Learn state export techniques

## 📋 Step-by-Step Demo

### Step 1: Create "Existing" Infrastructure
```bash
# Create the existing resources first
terraform init
terraform apply -auto-approve

# Note the resource IDs for import
terraform output
```

### Step 2: Prepare Import Project
```bash
# Get the resource information for import
VPC_ID=$(terraform output -raw vpc_id)
SUBNET_ID=$(terraform output -raw subnet_id)
SG_ID=$(terraform output -raw security_group_id)
INSTANCE_ID=$(terraform output -raw instance_id)
BUCKET_NAME=$(terraform output -raw bucket_name)

# Get the security group name (needed for import)
SG_NAME=$(aws ec2 describe-security-groups --group-ids $SG_ID --query 'SecurityGroups[0].GroupName' --output text)

echo "Resources to import:"
echo "VPC: $VPC_ID"
echo "Subnet: $SUBNET_ID"
echo "Security Group: $SG_ID ($SG_NAME)"
echo "Instance: $INSTANCE_ID"
echo "Bucket: $BUCKET_NAME"
```

### Step 3: Initialize Import Project
```bash
cd import-project

# Initialize the new project
terraform init

# Create terraform.tfvars with the resource names
cat > terraform.tfvars << EOF
security_group_name = "$SG_NAME"
bucket_name = "$BUCKET_NAME"
EOF
```

### Step 4: Import Resources One by One
```bash
# Import VPC
terraform import aws_vpc.imported_vpc $VPC_ID

# Check what Terraform thinks should happen
terraform plan

# Import Subnet
terraform import aws_subnet.imported_subnet $SUBNET_ID
terraform plan

# Import Security Group
terraform import aws_security_group.imported_sg $SG_ID
terraform plan

# Import EC2 Instance
terraform import aws_instance.imported_instance $INSTANCE_ID
terraform plan

# Import S3 Bucket
terraform import aws_s3_bucket.imported_bucket $BUCKET_NAME
terraform plan
```

### Step 5: Handle Import Differences
```bash
# After all imports, check for differences
terraform plan

# Common issues and fixes:
# 1. Missing optional attributes
# 2. Computed vs configured values
# 3. Default values that don't match

# Show detailed differences
terraform plan -detailed-exitcode
```

### Step 6: Bulk Import Script
```bash
# Create a bulk import script
cat > bulk-import.sh << EOF
#!/bin/bash
set -e

echo "Starting bulk import..."

terraform import aws_vpc.imported_vpc $VPC_ID
echo "✓ VPC imported"

terraform import aws_subnet.imported_subnet $SUBNET_ID
echo "✓ Subnet imported"

terraform import aws_security_group.imported_sg $SG_ID
echo "✓ Security Group imported"

terraform import aws_instance.imported_instance $INSTANCE_ID
echo "✓ Instance imported"

terraform import aws_s3_bucket.imported_bucket $BUCKET_NAME
echo "✓ Bucket imported"

echo "All resources imported successfully!"
terraform plan
EOF

chmod +x bulk-import.sh
```

### Step 7: State Export and Analysis
```bash
# Export current state
terraform state pull > imported-state.json

# Analyze the imported state
cat imported-state.json | jq '.resources | length'
cat imported-state.json | jq '.resources[].type' | sort | uniq -c

# Show specific resource in state
terraform state show aws_instance.imported_instance

# List all imported resources
terraform state list
```

### Step 8: Advanced Import Scenarios
```bash
# Import with different resource names
terraform import aws_vpc.production_vpc $VPC_ID

# Import into modules (if using modules)
# terraform import module.networking.aws_vpc.main $VPC_ID

# Import with count or for_each
# terraform import 'aws_instance.web[0]' $INSTANCE_ID
```

## 🔍 Key Observations to Discuss

### 1. Import Process
- Resource configuration must exist before import
- Import only adds to state, doesn't create resources
- Configuration must match existing resource

### 2. Common Import Issues
- Missing required attributes
- Computed vs configured values
- Resource naming conflicts
- Dependency resolution

### 3. Import Best Practices
- Write configuration first
- Import in dependency order
- Verify with terraform plan
- Handle differences systematically

### 4. State File Changes
- Resources added to state
- Metadata preserved
- Dependencies established

## 🧪 Interactive Exercises

### Exercise 1: Import Conflict Resolution
```bash
# Intentionally create a mismatch
# Edit main.tf to change instance_type to t3.micro
terraform plan  # See the difference

# Options to resolve:
# 1. Update configuration to match reality
# 2. Apply to change the resource
# 3. Remove and re-import
```

### Exercise 2: Partial Import
```bash
# Import only some resources
terraform state rm aws_instance.imported_instance
terraform state rm aws_s3_bucket.imported_bucket

# Verify partial state
terraform state list
terraform plan  # Should show resources to be created
```

### Exercise 3: Import Validation
```bash
# Create validation script
cat > validate-import.py << 'EOF'
#!/usr/bin/env python3
import json
import subprocess

def get_terraform_resources():
    result = subprocess.run(['terraform', 'state', 'list'], 
                          capture_output=True, text=True)
    return result.stdout.strip().split('\n')

def get_aws_resources():
    # This would query AWS API to get actual resources
    # Simplified for demo
    return ['vpc-123', 'subnet-456', 'sg-789', 'i-abc', 'bucket-def']

terraform_resources = get_terraform_resources()
print(f"Terraform manages {len(terraform_resources)} resources:")
for resource in terraform_resources:
    print(f"  - {resource}")
EOF

python3 validate-import.py
```

### Exercise 4: Export for Migration
```bash
# Export state for migration to another environment
terraform state pull > production-state-backup.json

# Extract specific resources for partial migration
cat production-state-backup.json | jq '.resources[] | select(.type=="aws_vpc")' > vpc-only.json

# Create import commands for another environment
cat production-state-backup.json | jq -r '.resources[] | "terraform import \(.type).\(.name) \(.instances[0].attributes.id)"' > import-commands.sh
```

## 🎓 Learning Outcomes
After this demo, students should understand:
- How to import existing resources into Terraform
- Common import challenges and solutions
- Bulk import strategies
- State export and analysis techniques
- Import validation and troubleshooting

## 🧹 Cleanup
```bash
# Destroy imported resources
terraform destroy -auto-approve

# Go back to parent directory and destroy original resources
cd ../
terraform destroy -auto-approve
```