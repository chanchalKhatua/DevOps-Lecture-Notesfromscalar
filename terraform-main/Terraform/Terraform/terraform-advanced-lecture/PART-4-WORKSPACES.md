# Part 4: Workspaces and Multi-Environment Management (30 minutes)

## 🏢 Workspace Strategies (15 minutes)

### Understanding Terraform Workspaces

Terraform workspaces allow you to manage multiple environments (dev, staging, prod) with the same configuration while maintaining separate state files.

### Workspace Fundamentals

#### Default Workspace
```bash
# Every Terraform configuration starts with 'default' workspace
terraform workspace show  # Shows: default
```

#### Workspace Operations
```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new development
terraform workspace new staging
terraform workspace new production

# Switch between workspaces
terraform workspace select development

# Delete workspace (must be empty)
terraform workspace delete staging
```

### Workspace-Aware Configuration

#### Using terraform.workspace
```hcl
# Variable configuration based on workspace
locals {
  environment_config = {
    development = {
      instance_type = "t2.micro"
      instance_count = 1
      enable_monitoring = false
    }
    staging = {
      instance_type = "t2.small"
      instance_count = 2
      enable_monitoring = true
    }
    production = {
      instance_type = "t3.medium"
      instance_count = 3
      enable_monitoring = true
    }
  }
  
  current_config = local.environment_config[terraform.workspace]
}

# Use workspace-specific values
resource "aws_instance" "web" {
  count         = local.current_config.instance_count
  instance_type = local.current_config.instance_type
  
  tags = {
    Name = "${terraform.workspace}-web-${count.index + 1}"
    Environment = terraform.workspace
  }
}
```

#### Workspace-Specific Resources
```hcl
# Conditional resources based on workspace
resource "aws_cloudwatch_dashboard" "monitoring" {
  count = local.current_config.enable_monitoring ? 1 : 0
  
  dashboard_name = "${terraform.workspace}-monitoring"
  # dashboard configuration
}

# Environment-specific naming
resource "aws_s3_bucket" "app_data" {
  bucket = "myapp-${terraform.workspace}-data-${random_id.suffix.hex}"
  
  tags = {
    Environment = terraform.workspace
  }
}
```

### Workspace State Management

#### State File Organization
```
# Local backend
terraform.tfstate.d/
├── development/
│   └── terraform.tfstate
├── staging/
│   └── terraform.tfstate
└── production/
    └── terraform.tfstate

# S3 backend
s3://my-terraform-state/
├── env:/development/myapp/terraform.tfstate
├── env:/staging/myapp/terraform.tfstate
└── env:/production/myapp/terraform.tfstate
```

#### Backend Configuration for Workspaces
```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "myapp/terraform.tfstate"
    region = "us-west-2"
    
    # Workspace-specific state paths
    workspace_key_prefix = "env"
  }
}
```

---

## 🏗️ Multi-Environment Architecture Patterns

### Pattern 1: Single Configuration, Multiple Workspaces
```hcl
# main.tf - Single configuration for all environments
variable "environment_configs" {
  type = map(object({
    instance_type     = string
    instance_count    = number
    enable_monitoring = bool
    db_instance_class = string
  }))
  
  default = {
    dev = {
      instance_type     = "t2.micro"
      instance_count    = 1
      enable_monitoring = false
      db_instance_class = "db.t3.micro"
    }
    staging = {
      instance_type     = "t2.small"
      instance_count    = 2
      enable_monitoring = true
      db_instance_class = "db.t3.small"
    }
    prod = {
      instance_type     = "t3.medium"
      instance_count    = 3
      enable_monitoring = true
      db_instance_class = "db.t3.medium"
    }
  }
}

locals {
  config = var.environment_configs[terraform.workspace]
}
```

### Pattern 2: Directory-Based Environments
```
environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
```

### Pattern 3: Module-Based with Environment Configs
```hcl
# environments/dev/main.tf
module "infrastructure" {
  source = "../../modules/infrastructure"
  
  environment       = "dev"
  instance_type     = "t2.micro"
  instance_count    = 1
  enable_monitoring = false
}

# environments/prod/main.tf
module "infrastructure" {
  source = "../../modules/infrastructure"
  
  environment       = "prod"
  instance_type     = "t3.large"
  instance_count    = 5
  enable_monitoring = true
}
```

---

## 🔄 Workspace Best Practices

### 1. Naming Conventions
```bash
# Use consistent workspace names
terraform workspace new dev-us-west-2
terraform workspace new staging-us-west-2
terraform workspace new prod-us-west-2

# Or environment-focused
terraform workspace new development
terraform workspace new staging
terraform workspace new production
```

### 2. Workspace Validation
```hcl
# Validate workspace names
locals {
  allowed_workspaces = ["development", "staging", "production"]
}

# Validation check
resource "null_resource" "workspace_validation" {
  count = contains(local.allowed_workspaces, terraform.workspace) ? 0 : 1
  
  provisioner "local-exec" {
    command = "echo 'Invalid workspace: ${terraform.workspace}. Allowed: ${join(\", \", local.allowed_workspaces)}' && exit 1"
  }
}
```

### 3. Environment-Specific Variables
```hcl
# variables.tf
variable "environment_settings" {
  description = "Environment-specific settings"
  type = map(object({
    vpc_cidr          = string
    availability_zones = list(string)
    instance_type     = string
    min_size          = number
    max_size          = number
    desired_capacity  = number
  }))
  
  default = {
    development = {
      vpc_cidr          = "10.0.0.0/16"
      availability_zones = ["us-west-2a"]
      instance_type     = "t2.micro"
      min_size          = 1
      max_size          = 2
      desired_capacity  = 1
    }
    production = {
      vpc_cidr          = "10.1.0.0/16"
      availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
      instance_type     = "t3.medium"
      min_size          = 3
      max_size          = 10
      desired_capacity  = 5
    }
  }
}

locals {
  env_config = var.environment_settings[terraform.workspace]
}
```

### 4. Workspace-Aware Outputs
```hcl
# outputs.tf
output "environment_info" {
  value = {
    workspace     = terraform.workspace
    vpc_id        = aws_vpc.main.id
    instance_ids  = aws_instance.web[*].id
    load_balancer = aws_lb.main.dns_name
    environment   = terraform.workspace
  }
}

output "workspace_specific_urls" {
  value = {
    application_url = "https://${terraform.workspace}.myapp.com"
    admin_url      = "https://${terraform.workspace}-admin.myapp.com"
  }
}
```

---

## ⚠️ Workspace Limitations and Alternatives

### Workspace Limitations
1. **Single Backend**: All workspaces share the same backend configuration
2. **No Isolation**: Workspaces in same backend can interfere
3. **Limited Metadata**: No built-in environment metadata
4. **Accidental Cross-Environment Changes**: Easy to apply to wrong workspace

### Alternative Approaches

#### 1. Separate State Backends
```hcl
# dev/backend.tf
terraform {
  backend "s3" {
    bucket = "myapp-terraform-state-dev"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

# prod/backend.tf
terraform {
  backend "s3" {
    bucket = "myapp-terraform-state-prod"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}
```

#### 2. Terragrunt for Environment Management
```hcl
# terragrunt.hcl
terraform {
  source = "../../modules/infrastructure"
}

inputs = {
  environment = "production"
  region      = "us-west-2"
}

remote_state {
  backend = "s3"
  config = {
    bucket = "myapp-terraform-state-${get_env("ENVIRONMENT")}"
    key    = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-west-2"
  }
}
```

#### 3. Terraform Cloud Workspaces
- True workspace isolation
- Environment-specific variables
- Policy enforcement
- Team access controls

---

## 🎯 Demo 6 Preview: Multi-Environment Setup (15 minutes)

### What We'll Build
- Single Terraform configuration
- Multiple workspaces (dev, staging, prod)
- Environment-specific configurations
- Workspace switching and management
- Cross-workspace data sharing

### Key Learning Outcomes
- Master workspace operations
- Implement environment-specific logic
- Understand workspace limitations
- Practice multi-environment workflows
- Learn workspace best practices

### Demo Scenarios
1. **Workspace Creation and Management**
2. **Environment-Specific Resource Configuration**
3. **Workspace State Isolation**
4. **Cross-Environment Data Sharing**
5. **Workspace Validation and Safety**