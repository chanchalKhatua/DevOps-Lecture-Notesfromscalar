# Live Project: End-to-End Web Application Deployment

## 🚀 Project Overview
Complete production-ready web application infrastructure using Terraform with:
- **VPC** with public/private subnets across multiple AZs
- **IAM** roles and policies for security
- **S3** for static assets and application storage
- **EC2** instances with Auto Scaling
- **ALB** (Application Load Balancer) for high availability
- **RDS** MySQL database with Multi-AZ
- **CloudWatch** monitoring and logging
- **Route53** for DNS management
- **CloudFront** CDN for global distribution
- **WAF** for web application security

## 📁 Project Structure
```
Live-Project/
├── modules/                    # Reusable Terraform modules
│   ├── vpc/                   # VPC, subnets, routing
│   ├── security/              # Security groups, IAM, WAF
│   ├── compute/               # EC2, ASG, ALB
│   ├── storage/               # S3, EFS
│   ├── database/              # RDS MySQL
│   └── monitoring/            # CloudWatch, SNS
├── environments/              # Environment-specific configs
│   ├── dev/                   # Development environment
│   ├── staging/               # Staging environment
│   └── prod/                  # Production environment
├── scripts/                   # Deployment and utility scripts
├── docs/                      # Documentation
└── README.md
```

## 🎯 Learning Objectives
- Master modular Terraform architecture
- Implement AWS best practices for security and scalability
- Deploy multi-tier web applications
- Manage multiple environments with Terraform
- Implement monitoring and logging
- Practice infrastructure as code principles

## 🛠️ Technologies Used
- **Terraform** v1.5+
- **AWS Provider** v5.0+
- **AWS Services**: VPC, EC2, ALB, RDS, S3, CloudFront, Route53, WAF, CloudWatch
- **Application**: Node.js web application with MySQL backend

## 🚀 Quick Start
```bash
# 1. Clone and navigate
cd Live-Project

# 2. Deploy development environment
cd environments/dev
terraform init
terraform plan
terraform apply

# 3. Access your application
terraform output application_url
```

## 📚 What You'll Learn
1. **Infrastructure Design Patterns**
2. **Security Best Practices**
3. **High Availability Architecture**
4. **Monitoring and Observability**
5. **Cost Optimization**
6. **Disaster Recovery**