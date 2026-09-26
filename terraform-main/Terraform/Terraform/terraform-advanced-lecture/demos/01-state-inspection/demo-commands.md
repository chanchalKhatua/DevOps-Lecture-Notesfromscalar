# Demo 1: State File Inspection Commands

## 🎯 Demo Objectives
- Understand state file structure
- Learn state inspection commands
- See resource dependencies
- Practice state troubleshooting

## 📋 Step-by-Step Demo

### Step 1: Initialize and Apply
```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply -auto-approve
```

### Step 2: Basic State Inspection
```bash
# List all resources in state
terraform state list

# Show human-readable state
terraform show

# Show specific resource details
terraform state show aws_vpc.demo_vpc
terraform state show aws_instance.web_server
```

### Step 3: Examine Raw State File
```bash
# View the raw JSON state file
cat terraform.tfstate | jq '.'

# Check state file metadata
cat terraform.tfstate | jq '.version, .terraform_version, .serial, .lineage'

# View specific resource in state
cat terraform.tfstate | jq '.resources[] | select(.name=="web_server")'
```

### Step 4: State Dependencies Analysis
```bash
# Show resource dependencies
terraform graph | dot -Tpng > dependency-graph.png

# Alternative: Use terraform show with grep
terraform show | grep -A 5 -B 5 "depends_on"
```

### Step 5: State Refresh and Drift Detection
```bash
# Refresh state from real infrastructure
terraform refresh

# Check for configuration drift
terraform plan

# Show outputs
terraform output
```

### Step 6: Advanced State Inspection
```bash
# Show state in JSON format
terraform show -json | jq '.'

# Extract specific attributes
terraform show -json | jq '.values.root_module.resources[] | select(.name=="web_server") | .values.public_ip'

# Check resource count
terraform state list | wc -l
```

## 🔍 Key Observations to Discuss

### 1. State File Structure
- Version and metadata
- Resource hierarchy
- Attribute storage
- Dependency tracking

### 2. Resource Relationships
- Implicit dependencies (references)
- Explicit dependencies (depends_on)
- Data source relationships

### 3. State Metadata
- Serial number increments
- Lineage uniqueness
- Provider information

### 4. Common Issues
- State drift detection
- Missing resources
- Attribute changes

## 🧪 Interactive Exercises

### Exercise 1: Manual State Modification
```bash
# DANGEROUS: Don't do this in production!
# Show what happens when state is manually modified
cp terraform.tfstate terraform.tfstate.backup
# Manually edit instance_type in state file
terraform plan  # See the drift
cp terraform.tfstate.backup terraform.tfstate  # Restore
```

### Exercise 2: Resource Dependency Chain
```bash
# Trace dependency chain
terraform state show aws_instance.web_server | grep -E "(subnet_id|vpc_security_group_ids)"
terraform state show aws_subnet.public_subnet | grep vpc_id
terraform state show aws_vpc.demo_vpc
```

### Exercise 3: State File Size Analysis
```bash
# Analyze state file size and complexity
ls -la terraform.tfstate*
wc -l terraform.tfstate
cat terraform.tfstate | jq '.resources | length'
```

## 🎓 Learning Outcomes
After this demo, students should understand:
- How Terraform tracks infrastructure in state
- The relationship between configuration and state
- How to inspect and troubleshoot state issues
- The importance of state file integrity

## 🧹 Cleanup
```bash
# Destroy the infrastructure
terraform destroy -auto-approve

# Verify state is empty
terraform state list
```