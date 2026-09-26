#!/bin/bash

# Deployment script for the Live Project
# Usage: ./deploy.sh <environment> [action]
# Example: ./deploy.sh dev apply

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment is provided
if [ $# -lt 1 ]; then
    print_error "Usage: $0 <environment> [action]"
    print_error "Environments: dev, staging, prod"
    print_error "Actions: plan, apply, destroy, output"
    exit 1
fi

ENVIRONMENT=$1
ACTION=${2:-plan}

# Validate environment
case $ENVIRONMENT in
    dev|staging|prod)
        print_status "Deploying to $ENVIRONMENT environment"
        ;;
    *)
        print_error "Invalid environment: $ENVIRONMENT"
        print_error "Valid environments: dev, staging, prod"
        exit 1
        ;;
esac

# Validate action
case $ACTION in
    plan|apply|destroy|output|init)
        print_status "Running terraform $ACTION"
        ;;
    *)
        print_error "Invalid action: $ACTION"
        print_error "Valid actions: init, plan, apply, destroy, output"
        exit 1
        ;;
esac

# Set working directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_DIR="$PROJECT_DIR/environments/$ENVIRONMENT"

# Check if environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    print_error "Environment directory not found: $ENV_DIR"
    exit 1
fi

# Change to environment directory
cd "$ENV_DIR"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_warning "terraform.tfvars not found. Please copy terraform.tfvars.example to terraform.tfvars and update the values."
    if [ -f "terraform.tfvars.example" ]; then
        print_status "Example file available: terraform.tfvars.example"
    fi
    exit 1
fi

# Pre-deployment checks
print_status "Running pre-deployment checks..."

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI not found. Please install AWS CLI."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure'."
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    print_error "Terraform not found. Please install Terraform."
    exit 1
fi

print_success "Pre-deployment checks passed"

# Initialize Terraform if .terraform directory doesn't exist
if [ ! -d ".terraform" ] || [ "$ACTION" = "init" ]; then
    print_status "Initializing Terraform..."
    terraform init
fi

# Execute the requested action
case $ACTION in
    plan)
        print_status "Creating Terraform plan..."
        terraform plan -out="$ENVIRONMENT.tfplan"
        print_success "Plan created successfully. Review the plan above."
        print_status "To apply the plan, run: ./deploy.sh $ENVIRONMENT apply"
        ;;
    apply)
        if [ -f "$ENVIRONMENT.tfplan" ]; then
            print_status "Applying Terraform plan..."
            terraform apply "$ENVIRONMENT.tfplan"
            rm -f "$ENVIRONMENT.tfplan"
        else
            print_status "No plan file found. Running apply with auto-approve..."
            print_warning "This will apply changes without showing a plan first."
            read -p "Are you sure you want to continue? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                terraform apply -auto-approve
            else
                print_status "Apply cancelled."
                exit 0
            fi
        fi
        print_success "Infrastructure deployed successfully!"
        print_status "Getting outputs..."
        terraform output
        ;;
    destroy)
        print_warning "This will destroy all infrastructure in the $ENVIRONMENT environment!"
        read -p "Are you sure you want to destroy everything? Type 'yes' to confirm: " -r
        if [ "$REPLY" = "yes" ]; then
            print_status "Destroying infrastructure..."
            terraform destroy -auto-approve
            print_success "Infrastructure destroyed successfully!"
        else
            print_status "Destroy cancelled."
        fi
        ;;
    output)
        print_status "Terraform outputs:"
        terraform output
        ;;
esac

print_success "Operation completed successfully!"