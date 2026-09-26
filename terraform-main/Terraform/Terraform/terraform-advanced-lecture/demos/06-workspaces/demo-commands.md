# Demo 6: Multi-Environment Workspaces Commands

## 🎯 Demo Objectives
- Master workspace operations
- Implement environment-specific configurations
- Understand workspace state isolation
- Practice multi-environment workflows
- Learn workspace best practices

## 📋 Step-by-Step Demo

### Step 1: Initialize and Explore Default Workspace
```bash
# Initialize Terraform
terraform init

# Check current workspace
terraform workspace show

# List all workspaces
terraform workspace list

# Validate configuration
terraform validate
```

### Step 2: Create Development Environment
```bash
# Create development workspace
terraform workspace new development

# Verify we're in development workspace
terraform workspace show

# Plan development environment
terraform plan

# Apply development environment
terraform apply -auto-approve

# Check outputs
terraform output
terraform output environment_summary
```

### Step 3: Create Staging Environment
```bash
# Create and switch to staging workspace
terraform workspace new staging

# Verify workspace switch
terraform workspace show

# Plan staging environment (notice differences)
terraform plan

# Apply staging environment
terraform apply -auto-approve

# Compare outputs with development
terraform output environment_summary
```

### Step 4: Create Production Environment
```bash
# Create production workspace
terraform workspace new production

# Plan production environment
terraform plan

# Apply production environment
terraform apply -auto-approve

# Check production-specific features
terraform output environment_summary
terraform output monitoring_info
```

### Step 5: Workspace State Isolation
```bash
# List resources in production
terraform state list

# Switch to development
terraform workspace select development

# List resources in development (different state)
terraform state list

# Switch to staging
terraform workspace select staging
terraform state list

# Show workspace-specific state files
ls -la terraform.tfstate.d/
```

### Step 6: Environment Comparison
```bash
# Create comparison script
cat > compare-environments.sh << 'EOF'
#!/bin/bash

echo "=== ENVIRONMENT COMPARISON ==="
echo

for env in development staging production; do
    echo "--- $env Environment ---"
    terraform workspace select $env > /dev/null 2>&1
    terraform output -json environment_summary | jq -r '
        "Instance Count: " + (.instance_count | tostring) + 
        " | Instance Type: " + .instance_type + 
        " | DB Class: " + .database_class + 
        " | Monitoring: " + (.monitoring | tostring)'
    echo
done
EOF

chmod +x compare-environments.sh
./compare-environments.sh
```

### Step 7: Cross-Environment Data Sharing
```bash
# Create data sharing example
cat > data-sharing-example.tf << 'EOF'
# Example: Reference production VPC from staging
data "terraform_remote_state" "production" {
  count = terraform.workspace == "staging" ? 1 : 0
  
  backend = "local"
  
  config = {
    path = "${path.module}/terraform.tfstate.d/production/terraform.tfstate"
  }
}

# Use production VPC CIDR for staging security group rules
locals {
  production_vpc_cidr = terraform.workspace == "staging" && length(data.terraform_remote_state.production) > 0 ? 
                       data.terraform_remote_state.production[0].outputs.vpc_info.vpc_cidr : 
                       null
}
EOF

# Apply the data sharing configuration
terraform workspace select staging
terraform apply -auto-approve
```

### Step 8: Workspace Management Operations
```bash
# Show all workspaces with details
terraform workspace list

# Switch between workspaces
terraform workspace select development
terraform workspace select production
terraform workspace select staging

# Try to delete a workspace with resources (should fail)
terraform workspace select development
terraform workspace delete staging  # This will fail

# Proper workspace deletion process
terraform workspace select staging
terraform destroy -auto-approve
terraform workspace select development
terraform workspace delete staging  # Now it works
```

### Step 9: Advanced Workspace Operations
```bash
# Workspace-specific variable files
cat > development.tfvars << 'EOF'
# Development-specific overrides
aws_region = "us-west-2"
EOF

cat > production.tfvars << 'EOF'
# Production-specific overrides
aws_region = "us-east-1"
EOF

# Apply with workspace-specific variables
terraform workspace select development
terraform apply -var-file="development.tfvars" -auto-approve

terraform workspace select production
terraform apply -var-file="production.tfvars" -auto-approve
```

### Step 10: Workspace Automation Scripts
```bash
# Create workspace management script
cat > manage-workspaces.sh << 'EOF'
#!/bin/bash

function deploy_environment() {
    local env=$1
    echo "Deploying $env environment..."
    
    terraform workspace select $env || terraform workspace new $env
    terraform plan -out="$env.tfplan"
    terraform apply "$env.tfplan"
    
    echo "$env deployment completed!"
    terraform output environment_summary
}

function destroy_environment() {
    local env=$1
    echo "Destroying $env environment..."
    
    terraform workspace select $env
    terraform destroy -auto-approve
    
    echo "$env environment destroyed!"
}

function list_environments() {
    echo "Available environments:"
    terraform workspace list
    
    echo -e "\nCurrent environment details:"
    terraform workspace show
    terraform output environment_summary 2>/dev/null || echo "No resources deployed"
}

case "$1" in
    deploy)
        deploy_environment $2
        ;;
    destroy)
        destroy_environment $2
        ;;
    list)
        list_environments
        ;;
    *)
        echo "Usage: $0 {deploy|destroy|list} [environment]"
        echo "Example: $0 deploy development"
        exit 1
        ;;
esac
EOF

chmod +x manage-workspaces.sh

# Use the script
./manage-workspaces.sh list
./manage-workspaces.sh deploy development
```

## 🔍 Key Observations to Discuss

### 1. Workspace State Isolation
- Each workspace has its own state file
- Resources are completely isolated
- No cross-workspace interference

### 2. Environment-Specific Configuration
- Single configuration adapts to workspace
- Environment-specific resource sizing
- Conditional resource creation

### 3. Workspace Naming and Organization
- Consistent naming conventions
- Environment-based resource tags
- Workspace validation

### 4. Multi-Environment Management
- Easy environment switching
- Consistent deployment process
- Environment comparison capabilities

## 🧪 Interactive Exercises

### Exercise 1: Workspace Validation
```bash
# Try creating an invalid workspace
terraform workspace new invalid-env

# See the validation error
terraform plan
```

### Exercise 2: Resource Scaling Comparison
```bash
# Compare resource counts across environments
for env in development staging production; do
    terraform workspace select $env
    echo "=== $env ==="
    terraform state list | wc -l
    echo "Resources: $(terraform state list | wc -l)"
done
```

### Exercise 3: Cost Analysis by Environment
```bash
# Create cost analysis script
cat > cost-analysis.sh << 'EOF'
#!/bin/bash

for env in development staging production; do
    terraform workspace select $env > /dev/null 2>&1
    
    echo "=== $env Cost Factors ==="
    terraform output -json environment_summary | jq -r '
        "Instances: " + (.instance_count | tostring) + " x " + .instance_type + 
        " | DB: " + .database_class + 
        " | Multi-AZ: " + (.multi_az_db | tostring)'
    echo
done
EOF

chmod +x cost-analysis.sh
./cost-analysis.sh
```

### Exercise 4: Environment Health Check
```bash
# Create health check script
cat > health-check.sh << 'EOF'
#!/bin/bash

function check_environment() {
    local env=$1
    terraform workspace select $env > /dev/null 2>&1
    
    echo "Checking $env environment..."
    
    # Check if resources exist
    resource_count=$(terraform state list | wc -l)
    echo "  Resources: $resource_count"
    
    # Check if plan is clean
    if terraform plan -detailed-exitcode > /dev/null 2>&1; then
        echo "  Status: ✅ Clean (no changes needed)"
    else
        echo "  Status: ⚠️  Drift detected"
    fi
    
    # Get application URL
    app_url=$(terraform output -raw load_balancer_info 2>/dev/null | jq -r '.url' 2>/dev/null)
    if [ "$app_url" != "null" ] && [ -n "$app_url" ]; then
        echo "  URL: $app_url"
    fi
    
    echo
}

for env in development staging production; do
    check_environment $env
done
EOF

chmod +x health-check.sh
./health-check.sh
```

## 🎓 Learning Outcomes
After this demo, students should understand:
- How to create and manage Terraform workspaces
- Environment-specific configuration patterns
- Workspace state isolation benefits
- Multi-environment deployment strategies
- Workspace best practices and limitations

## 🧹 Cleanup
```bash
# Destroy all environments
for env in development staging production; do
    echo "Destroying $env..."
    terraform workspace select $env
    terraform destroy -auto-approve
done

# Switch back to default and clean up workspaces
terraform workspace select default
terraform workspace delete development
terraform workspace delete staging  
terraform workspace delete production

# Verify cleanup
terraform workspace list
ls -la terraform.tfstate.d/ 2>/dev/null || echo "Workspace directories cleaned up"
```