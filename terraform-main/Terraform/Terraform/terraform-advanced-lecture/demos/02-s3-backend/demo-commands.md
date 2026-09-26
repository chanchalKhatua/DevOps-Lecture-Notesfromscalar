# Demo 2: S3 Backend Setup Commands

## 🎯 Demo Objectives
- Create S3 backend infrastructure
- Migrate from local to remote state
- Understand backend configuration
- Test state locking mechanism

## 📋 Step-by-Step Demo

### Step 1: Create Backend Infrastructure
```bash
# Initialize and create the backend infrastructure
terraform init
terraform plan
terraform apply -auto-approve

# Note the outputs - we'll need them for backend configuration
terraform output
```

### Step 2: Prepare Application Infrastructure
```bash
# Copy our previous demo to a new directory
cp -r ../01-state-inspection ./app-with-remote-state
cd app-with-remote-state
```

### Step 3: Configure Remote Backend
```bash
# Get the backend configuration values
cd ../
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name)
KMS_KEY_ID=$(terraform output -raw kms_key_id)

echo "Backend Configuration:"
echo "Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $DYNAMODB_TABLE"
echo "KMS Key: $KMS_KEY_ID"
```

Create backend configuration file:
```bash
cd app-with-remote-state
cat > backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "$BUCKET_NAME"
    key            = "demo/app/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "$DYNAMODB_TABLE"
    kms_key_id     = "$KMS_KEY_ID"
  }
}
EOF
```

### Step 4: Initialize Backend Migration
```bash
# Initialize with the new backend
terraform init

# Terraform will ask if you want to migrate state
# Answer 'yes' to migrate from local to remote state
```

### Step 5: Verify Remote State
```bash
# Apply the configuration
terraform apply -auto-approve

# Verify state is stored remotely
aws s3 ls s3://$BUCKET_NAME/demo/app/ --recursive

# Check state file content in S3
aws s3 cp s3://$BUCKET_NAME/demo/app/terraform.tfstate - | jq '.version, .serial, .lineage'
```

### Step 6: Test State Locking
```bash
# Terminal 1: Start a long-running operation
terraform apply -auto-approve &
APPLY_PID=$!

# Terminal 2: Try to run another operation (should be blocked)
terraform plan  # This should show lock information

# Check DynamoDB for lock entry
aws dynamodb scan --table-name $DYNAMODB_TABLE

# Wait for first operation to complete
wait $APPLY_PID
```

### Step 7: Advanced Backend Operations
```bash
# Show backend configuration
terraform version
terraform providers

# Force unlock (if needed)
# terraform force-unlock <LOCK_ID>

# Reconfigure backend (if needed)
# terraform init -reconfigure
```

## 🔍 Key Observations to Discuss

### 1. State Migration Process
- Automatic detection of existing state
- Safe migration with confirmation
- Backup creation during migration

### 2. Remote State Benefits
- Centralized storage
- Team collaboration
- Automatic encryption
- Version history

### 3. Locking Mechanism
- Automatic lock acquisition
- Lock information in DynamoDB
- Conflict prevention
- Lock timeout handling

### 4. Security Features
- KMS encryption
- IAM access control
- S3 bucket policies
- DynamoDB permissions

## 🧪 Interactive Exercises

### Exercise 1: State File Versioning
```bash
# Make a change to trigger new state version
terraform apply -var="instance_type=t3.micro" -auto-approve

# Check S3 versions
aws s3api list-object-versions --bucket $BUCKET_NAME --prefix demo/app/

# Download and compare different versions
aws s3api get-object --bucket $BUCKET_NAME --key demo/app/terraform.tfstate --version-id <VERSION_ID> old-state.json
aws s3 cp s3://$BUCKET_NAME/demo/app/terraform.tfstate current-state.json
diff old-state.json current-state.json
```

### Exercise 2: Lock Conflict Simulation
```bash
# Create a script to simulate lock conflict
cat > simulate-conflict.sh << 'EOF'
#!/bin/bash
echo "Starting terraform apply in background..."
terraform apply -auto-approve &
APPLY_PID=$!

sleep 2
echo "Attempting second terraform operation..."
timeout 10 terraform plan || echo "Operation blocked by lock!"

wait $APPLY_PID
echo "First operation completed"
EOF

chmod +x simulate-conflict.sh
./simulate-conflict.sh
```

### Exercise 3: Backend State Analysis
```bash
# Analyze remote state structure
aws s3 cp s3://$BUCKET_NAME/demo/app/terraform.tfstate - | jq '.resources | length'
aws s3 cp s3://$BUCKET_NAME/demo/app/terraform.tfstate - | jq '.resources[].type' | sort | uniq -c

# Check state file size and metadata
aws s3api head-object --bucket $BUCKET_NAME --key demo/app/terraform.tfstate
```

## 🎓 Learning Outcomes
After this demo, students should understand:
- How to set up S3 backend infrastructure
- The state migration process
- Remote state benefits and features
- State locking mechanisms
- Security considerations for remote state

## 🧹 Cleanup
```bash
# Destroy application infrastructure
terraform destroy -auto-approve

# Verify S3 state file is updated
aws s3 ls s3://$BUCKET_NAME/demo/app/ --recursive

# Go back and destroy backend infrastructure
cd ../
terraform destroy -auto-approve
```