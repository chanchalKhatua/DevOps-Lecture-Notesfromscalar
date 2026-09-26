# Architecture Documentation - Live Project

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet                                │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                   CloudFront CDN                                │
│              (Global Distribution)                              │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                      WAF                                        │
│              (Web Application Firewall)                        │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                Application Load Balancer                       │
│                  (Multi-AZ Distribution)                       │
└─────────────┬───────────────────────────────────┬───────────────┘
              │                                   │
┌─────────────▼─────────────┐         ┌─────────────▼─────────────┐
│     Availability Zone A    │         │     Availability Zone B    │
│  ┌─────────────────────┐  │         │  ┌─────────────────────┐  │
│  │   Public Subnet     │  │         │  │   Public Subnet     │  │
│  │   (NAT Gateway)     │  │         │  │   (NAT Gateway)     │  │
│  └─────────────────────┘  │         │  └─────────────────────┘  │
│  ┌─────────────────────┐  │         │  ┌─────────────────────┐  │
│  │   Private Subnet    │  │         │  │   Private Subnet    │  │
│  │   (Web Servers)     │  │         │  │   (Web Servers)     │  │
│  └─────────────────────┘  │         │  └─────────────────────┘  │
│  ┌─────────────────────┐  │         │  ┌─────────────────────┐  │
│  │  Database Subnet    │  │         │  │  Database Subnet    │  │
│  │   (RDS MySQL)       │  │         │  │   (RDS Standby)     │  │
│  └─────────────────────┘  │         │  └─────────────────────┘  │
└───────────────────────────┘         └───────────────────────────┘
              │                                   │
              └─────────────┬───────────────────────┘
                           │
┌─────────────────────────▼───────────────────────────────────────┐
│                      S3 Bucket                                 │
│                 (Static Assets & Logs)                         │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Component Details

### 1. Network Layer (VPC Module)

#### VPC Configuration
- **CIDR Block**: 10.0.0.0/16 (65,536 IP addresses)
- **DNS Resolution**: Enabled
- **DNS Hostnames**: Enabled

#### Subnet Architecture
```
Public Subnets (Internet-facing):
├── AZ-A: 10.0.0.0/24   (256 IPs)
└── AZ-B: 10.0.1.0/24   (256 IPs)

Private Subnets (Application tier):
├── AZ-A: 10.0.10.0/24  (256 IPs)
└── AZ-B: 10.0.11.0/24  (256 IPs)

Database Subnets (Data tier):
├── AZ-A: 10.0.20.0/24  (256 IPs)
└── AZ-B: 10.0.21.0/24  (256 IPs)
```

#### Routing
- **Public Route Table**: Routes to Internet Gateway (0.0.0.0/0 → IGW)
- **Private Route Tables**: Routes to NAT Gateway (0.0.0.0/0 → NAT-GW)
- **Database Route Table**: No internet access (isolated)

#### NAT Gateways
- **High Availability**: One NAT Gateway per AZ
- **Elastic IPs**: Static public IPs for outbound traffic
- **Bandwidth**: Up to 45 Gbps

### 2. Security Layer (Security Module)

#### Security Groups
```
ALB Security Group:
├── Inbound: HTTP (80) from 0.0.0.0/0
├── Inbound: HTTPS (443) from 0.0.0.0/0
└── Outbound: All traffic

Web Security Group:
├── Inbound: Port 3000 from ALB SG
├── Inbound: SSH (22) from Bastion SG
└── Outbound: All traffic

Database Security Group:
├── Inbound: MySQL (3306) from Web SG
└── Outbound: None

Bastion Security Group:
├── Inbound: SSH (22) from Admin IPs
└── Outbound: All traffic
```

#### IAM Roles and Policies
```
EC2 Instance Role:
├── S3 Access (GetObject, PutObject, DeleteObject)
├── CloudWatch Logs (PutLogEvents, CreateLogGroup)
├── CloudWatch Metrics (PutMetricData)
└── EC2 Describe (DescribeVolumes, DescribeTags)

RDS Enhanced Monitoring Role:
└── RDS Enhanced Monitoring Policy
```

#### WAF Configuration
```
Web ACL Rules:
├── Rate Limiting: 2000 requests per 5 minutes per IP
├── AWS Managed Rules: Common Rule Set
├── AWS Managed Rules: Known Bad Inputs
└── Geographic Restrictions: Configurable
```

### 3. Compute Layer (Compute Module)

#### Application Load Balancer
- **Type**: Application Load Balancer (Layer 7)
- **Scheme**: Internet-facing
- **Subnets**: Public subnets across multiple AZs
- **Health Checks**: HTTP GET /health every 30 seconds

#### Auto Scaling Group
```
Configuration:
├── Launch Template: Latest version
├── Subnets: Private subnets (multi-AZ)
├── Health Check: ELB + EC2
├── Health Check Grace Period: 300 seconds
└── Termination Policies: Default

Scaling Policies:
├── Scale Up: CPU > 70% for 2 periods
├── Scale Down: CPU < 30% for 2 periods
├── Cooldown: 300 seconds
└── Metrics: CloudWatch CPU Utilization
```

#### EC2 Instances
```
Launch Template:
├── AMI: Amazon Linux 2 (latest)
├── Instance Type: Environment-specific
├── Security Groups: Web SG
├── IAM Instance Profile: EC2 Role
├── User Data: Application bootstrap script
└── EBS Encryption: Enabled
```

#### Bastion Host
- **Purpose**: Secure SSH access to private instances
- **Instance Type**: t3.micro
- **Subnet**: Public subnet (single AZ)
- **Security**: Restricted SSH access

### 4. Storage Layer (Storage Module)

#### S3 Bucket Configuration
```
Bucket Features:
├── Versioning: Enabled
├── Encryption: KMS with customer-managed key
├── Public Access: Blocked
├── Lifecycle Policy: IA (30d) → Glacier (90d) → Delete (365d)
└── Access Logging: Enabled
```

#### CloudFront Distribution
```
Origins:
├── S3 Bucket: Static assets (CSS, JS, images)
└── ALB: Dynamic content (API, HTML)

Cache Behaviors:
├── Default: S3 origin, TTL 3600s
├── /api/*: ALB origin, no caching
└── /health: ALB origin, no caching

Security:
├── Origin Access Control: S3 access
├── WAF Integration: Web ACL attached
└── HTTPS: Redirect HTTP to HTTPS
```

### 5. Database Layer (Database Module)

#### RDS MySQL Configuration
```
Engine Configuration:
├── Engine: MySQL 8.0.35
├── Instance Class: Environment-specific
├── Storage: GP3 with encryption
├── Multi-AZ: Production only
└── Parameter Group: Custom optimizations

Security:
├── Subnet Group: Database subnets
├── Security Group: Database SG
├── Encryption: KMS customer-managed key
└── Network: Private subnets only

Backup & Monitoring:
├── Automated Backups: 1-30 days retention
├── Backup Window: 03:00-04:00 UTC
├── Maintenance Window: Sunday 04:00-05:00 UTC
├── Enhanced Monitoring: 60-second intervals
└── Performance Insights: Enabled
```

#### Read Replica (Production)
- **Purpose**: Read scaling and disaster recovery
- **Configuration**: Same as primary with read-only access
- **Lag Monitoring**: CloudWatch metrics

## 🔄 Data Flow

### 1. User Request Flow
```
User Request → CloudFront → WAF → ALB → EC2 Instance → Response
                    ↓
              S3 (Static Assets)
```

### 2. API Request Flow
```
API Request → CloudFront → WAF → ALB → EC2 Instance → RDS → Response
```

### 3. Database Operations
```
Application → RDS Primary (Read/Write)
Application → RDS Replica (Read Only) [Production]
```

### 4. Logging and Monitoring
```
Application Logs → CloudWatch Logs
System Metrics → CloudWatch Metrics
Database Metrics → CloudWatch + Performance Insights
Access Logs → S3 Bucket
```

## 🔒 Security Architecture

### Defense in Depth
```
Layer 1: CloudFront + WAF (DDoS, Rate limiting)
Layer 2: ALB (SSL termination, Health checks)
Layer 3: Security Groups (Network-level filtering)
Layer 4: IAM Roles (Resource-level permissions)
Layer 5: Encryption (Data at rest and in transit)
Layer 6: VPC (Network isolation)
```

### Encryption Strategy
```
Data in Transit:
├── HTTPS: CloudFront to users
├── HTTP: ALB to EC2 (within VPC)
└── Encrypted: EC2 to RDS (SSL/TLS)

Data at Rest:
├── S3: KMS encryption
├── EBS: KMS encryption
├── RDS: KMS encryption
└── CloudWatch Logs: KMS encryption
```

## 📊 Monitoring and Observability

### CloudWatch Metrics
```
Application Metrics:
├── ALB: Request count, response time, error rate
├── EC2: CPU, memory, disk, network
├── RDS: CPU, connections, read/write IOPS
└── Custom: Application-specific metrics

Alarms:
├── High CPU: Scale up trigger
├── Low CPU: Scale down trigger
├── Database connections: Alert threshold
└── Application errors: Alert threshold
```

### Logging Strategy
```
Log Sources:
├── Application Logs: Custom application events
├── System Logs: OS-level events
├── Access Logs: ALB request logs
├── Database Logs: MySQL error, slow query logs
└── VPC Flow Logs: Network traffic analysis
```

## 🚀 Scalability Design

### Horizontal Scaling
- **Auto Scaling Groups**: Automatic instance scaling
- **Load Balancing**: Traffic distribution across instances
- **Database Read Replicas**: Read scaling (production)

### Vertical Scaling
- **Instance Types**: Easy upgrade path
- **RDS Scaling**: Storage and compute scaling
- **EBS Optimization**: Performance scaling

### Geographic Scaling
- **CloudFront**: Global edge locations
- **Multi-Region**: Future expansion capability
- **Cross-AZ**: High availability within region

## 💰 Cost Optimization

### Resource Optimization
```
Development:
├── Single AZ deployment
├── Smaller instance types
├── Reduced backup retention
└── CloudFront disabled

Production:
├── Reserved Instances for predictable workloads
├── Spot Instances for batch processing
├── S3 Lifecycle policies
└── CloudWatch log retention policies
```

### Monitoring Costs
- **AWS Cost Explorer**: Usage analysis
- **Billing Alerts**: Budget monitoring
- **Resource Tagging**: Cost allocation
- **Right-sizing**: Instance optimization

This architecture provides a robust, scalable, and secure foundation for web applications while maintaining cost efficiency across different environments.