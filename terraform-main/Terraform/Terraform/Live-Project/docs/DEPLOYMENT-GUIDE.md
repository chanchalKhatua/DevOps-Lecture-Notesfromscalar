# Deployment Guide - Live Project

## 🚀 Quick Start

### Prerequisites
1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Terraform** v1.5+ installed
4. **EC2 Key Pair** created in your AWS account

### Step 1: Clone and Setup
```bash
cd Live-Project
```

### Step 2: Create EC2 Key Pair (if not exists)
```bash
# Create a new key pair
aws ec2 create-key-pair --key-name webapp-dev-key --query 'KeyMaterial' --output text > webapp-dev-key.pem
chmod 400 webapp-dev-key.pem
```

### Step 3: Configure Variables
```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### Step 4: Deploy
```bash
# From project root
./scripts/deploy.sh dev plan    # Review the plan
./scripts/deploy.sh dev apply   # Deploy infrastructure
```

### Step 5: Access Your Application
```bash
# Get the application URL
./scripts/deploy.sh dev output
```

---

## 📋 Detailed Deployment Steps

### 1. Environment Setup

#### AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

#### Verify AWS Access
```bash
aws sts get-caller-identity
```

### 2. Infrastructure Components

The deployment creates:

#### Networking Layer
- **VPC** with public/private/database subnets across 2 AZs
- **Internet Gateway** for public internet access
- **NAT Gateways** for private subnet internet access
- **Route Tables** with appropriate routing

#### Security Layer
- **Security Groups** for ALB, web servers, database, and bastion
- **IAM Roles** and policies for EC2 instances
- **WAF** for web application protection
- **KMS Keys** for encryption

#### Compute Layer
- **Application Load Balancer** for high availability
- **Auto Scaling Group** with launch template
- **EC2 Instances** running Node.js application
- **Bastion Host** for secure SSH access

#### Storage Layer
- **S3 Bucket** for static assets with encryption
- **CloudFront** distribution (disabled in dev for cost savings)

#### Database Layer
- **RDS MySQL** instance with encryption
- **DB Subnet Group** across multiple AZs
- **Automated backups** and monitoring

### 3. Application Architecture

```
Internet → CloudFront → ALB → EC2 Instances → RDS MySQL
                ↓
              S3 Bucket
```

#### Application Features
- **Node.js** web application with Express framework
- **MySQL** database integration
- **Health check** endpoint at `/health`
- **API endpoints** for user management
- **Static file** serving from S3
- **CloudWatch** logging and monitoring

### 4. Environment-Specific Configurations

#### Development (dev)
- Single AZ deployment
- t3.micro instances
- No read replicas
- Minimal backup retention
- CloudFront disabled

#### Staging (staging)
- Multi-AZ deployment
- t3.small instances
- Enhanced monitoring
- 7-day backup retention
- CloudFront enabled

#### Production (prod)
- Multi-AZ deployment
- t3.medium+ instances
- Read replicas
- 30-day backup retention
- Full monitoring and alerting
- Deletion protection enabled

---

## 🔧 Management Commands

### Deployment Script Usage
```bash
./scripts/deploy.sh <environment> [action]
```

#### Available Actions
- `init` - Initialize Terraform
- `plan` - Create execution plan
- `apply` - Apply changes
- `destroy` - Destroy infrastructure
- `output` - Show outputs

#### Examples
```bash
# Development environment
./scripts/deploy.sh dev plan
./scripts/deploy.sh dev apply
./scripts/deploy.sh dev output
./scripts/deploy.sh dev destroy

# Staging environment
./scripts/deploy.sh staging plan
./scripts/deploy.sh staging apply

# Production environment
./scripts/deploy.sh prod plan
./scripts/deploy.sh prod apply
```

### Manual Terraform Commands
```bash
cd environments/dev

# Initialize
terraform init

# Plan
terraform plan -out=dev.tfplan

# Apply
terraform apply dev.tfplan

# Destroy
terraform destroy

# Show outputs
terraform output

# Show specific output
terraform output application_url
```

---

## 🔍 Monitoring and Troubleshooting

### Application Health Check
```bash
# Get application URL
APP_URL=$(terraform output -raw application_url)

# Test health endpoint
curl $APP_URL/health

# Test API endpoint
curl $APP_URL/api/users
```

### SSH Access via Bastion
```bash
# Get bastion IP
BASTION_IP=$(terraform output -raw bastion_ip)

# SSH to bastion
ssh -i webapp-dev-key.pem ec2-user@$BASTION_IP

# From bastion, SSH to web servers (get private IPs from AWS console)
ssh ec2-user@<private-ip>
```

### Database Access
```bash
# From web server or bastion
mysql -h <db-endpoint> -u admin -p appdb
```

### CloudWatch Logs
- Navigate to CloudWatch in AWS Console
- Check log groups: `/aws/rds/instance/webapp-dev-database/*`
- Application logs are in EC2 instance system logs

### Common Issues

#### 1. Key Pair Not Found
```bash
# Create the key pair
aws ec2 create-key-pair --key-name webapp-dev-key --query 'KeyMaterial' --output text > webapp-dev-key.pem
chmod 400 webapp-dev-key.pem
```

#### 2. Insufficient Permissions
Ensure your AWS user has the following policies:
- `PowerUserAccess` or specific permissions for EC2, RDS, S3, IAM, etc.

#### 3. Resource Limits
Check AWS service limits if resources fail to create:
- VPC limits
- EC2 instance limits
- RDS instance limits

#### 4. Application Not Responding
```bash
# Check Auto Scaling Group
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names webapp-dev-web-asg

# Check target group health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Check security groups
aws ec2 describe-security-groups --group-ids <security-group-id>
```

---

## 🔒 Security Considerations

### Production Checklist
- [ ] Restrict bastion access to specific IP ranges
- [ ] Enable GuardDuty for threat detection
- [ ] Configure AWS Config for compliance monitoring
- [ ] Set up CloudTrail for audit logging
- [ ] Enable VPC Flow Logs
- [ ] Configure backup and disaster recovery
- [ ] Set up monitoring and alerting
- [ ] Review IAM policies for least privilege
- [ ] Enable MFA for AWS accounts
- [ ] Configure SSL/TLS certificates for HTTPS

### Cost Optimization
- [ ] Use appropriate instance sizes
- [ ] Enable S3 lifecycle policies
- [ ] Configure RDS automated backups retention
- [ ] Use Spot instances for non-critical workloads
- [ ] Set up billing alerts
- [ ] Review and optimize CloudFront caching

---

## 📚 Next Steps

1. **Custom Domain**: Configure Route53 and SSL certificates
2. **CI/CD Pipeline**: Set up automated deployments
3. **Monitoring**: Configure detailed CloudWatch dashboards
4. **Backup Strategy**: Implement comprehensive backup and recovery
5. **Security Hardening**: Implement additional security measures
6. **Performance Optimization**: Fine-tune application and database performance