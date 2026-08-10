Personalized DevOps / Cloud / SRE Study Roadmap

Current Study Priorities

Area                   What you should do

Linux                  🔄 RevisionBash                   🔄 RevisionDocker                 🔄 RevisionJenkins                🔄 RevisionKubernetes             🔄 Deep revision nowAWS                    ✅ Fundamentals → apply in projectsNetworking             🟡 Fundamentals known → deepen graduallyTerraform              🔴 Learn from zero nextECR                    🟡 Learn through projectEKS                    🟡 Learn properly during EKS projectHelm                   🔜 After EKSArgo CD / GitOps       🔜 After HelmGitHub Actions         🔜 After GitOps foundationPython                 🟠 Relearn practical automation PythonHLD                    🔜 Start gradually with AWS/EKSPrometheus / Grafana   🔜 Project + SRE conceptsSecurity               🔜 Production hardeningAnsible                🔜 LaterSQL / DBMS             🟢 Maintain onlyDSA                    🟢 Low priority

AWS --- Pending / Advanced Areas

AWS fundamentals are already covered. Do not restart the beginner AWSsyllabus.

High priority

VPC deep networking

Public/private subnet architecture

Route tables

Internet Gateway

NAT Gateway

Security Groups and NACLs

ALB / NLB

IAM advanced concepts

ECR

EKS

EKS networking / VPC CNI

EKS IAM / IRSA / Pod Identity

AWS Load Balancer Controller

EKS autoscaling

Multi-AZ architecture

Medium priority

CloudWatch

Route 53

RDS architecture

ElastiCache / Redis

SQS / SNS

Secrets Manager

KMS

CloudTrail

VPC Flow Logs

VPC Endpoints / PrivateLink

Transit Gateway

Disaster Recovery

Cost optimization

AWS Well-Architected Framework

Later / optional

AWS Organizations

Multi-account architecture

Control Tower / Landing Zone

Project-Driven Learning Order

1. Current: Kubernetes + Jenkins Revision

Keep Linux, Bash, Docker, Git and Jenkins fresh through the existingproject.

2. Terraform From Zero

Learn: - Providers - Resources - Variables - Outputs - Locals - Datasources - count / for_each - Modules - State - Remote backend - Statelocking - Import - Drift - Lifecycle

3. AWS + Terraform Project

Build and understand: - VPC - Subnets - Routing - NAT - SecurityGroups - IAM - EC2 - ALB - ECR

4. EKS

Learn: - EKS architecture - Control plane - Node groups - VPC CNI - IAM/ Pod Identity - Load Balancer Controller - HPA - Cluster autoscaling -EKS networking and security

5. Helm

Learn: - Charts - values.yaml - Templates - Environment-specificvalues - Releases - Upgrades - Rollbacks

6. Argo CD / GitOps

Learn: - GitOps principles - Desired state - Applications -ApplicationSet - Sync - Auto-sync - Self-healing - Pruning - Rollback -Helm + Argo CD - Multi-environment GitOps

7. GitHub Actions

Build: GitHub → GitHub Actions → Test → Docker → ECR → GitOps Repository→ Argo CD → EKS

Learn: - Workflows - Jobs - Runners - Secrets - Artifacts -Environments - OIDC - AWS authentication

8. HLD / System Design

Learn gradually while designing the AWS/EKS project: - Scalability -High availability - Reliability - Fault tolerance - Load balancing -Caching - Queues - Replication - Sharding - Rate limiting - Retry -Circuit breaker - Idempotency - RTO / RPO - Multi-AZ - Disaster recovery

9. Prometheus / Grafana + SRE

Learn: - Metrics - Logs - Traces - SLI - SLO - SLA - Error budgets -RED - USE - Golden signals - Alerting - Incident management - MTTR -Postmortems

10. Security / DevSecOps

Learn: - IAM least privilege - Secrets - OIDC - TLS - Kubernetes RBAC -NetworkPolicy - Container security - Image scanning - Trivy - SBOM -SAST - Supply-chain security

11. Ansible

Learn after Terraform: - Inventory - Playbooks - Variables - Handlers -Templates - Roles - Idempotency - Vault

Mental model:

Terraform → provision infrastructureAnsible → configure infrastructure

Python

Do not prioritize advanced DSA.

Relearn practical Python for DevOps automation: - Variables -Conditions - Loops - Functions - Lists - Dictionaries - Strings -Files - Exceptions - Modules - JSON - YAML - APIs / requests -subprocess - OS/system operations - boto3

Use Python for AWS, Kubernetes, API, CI/CD and automation scripts.

SQL / DBMS

Do not restart the full module.

Maintain enough knowledge to understand: - Indexes - Transactions -Replication - Performance - Database bottlenecks - High availability

DSA

Low priority for the DevOps / Cloud / Platform / SRE path.

Do not spend months on advanced DSA unless a specific target jobrequires it.

Scaler Recording Strategy

Do not watch recordings chronologically.

Use the project-driven order above.

Known useful recordings: - Day 127 --- End-to-End CI/CD Pipeline:Jenkins, Docker, and Kubernetes Integration: revision now - Day 166--- EKS Fundamentals: Basics: watch around the EKS stage - Day 194--- Advanced Terraform Concepts: watch after learning Terraformfundamentals - 22 Jan --- Introduction to GitHub Actions: watchduring the GitHub Actions stage - Day 91 --- High Availability andReplication: watch around AWS/HLD architecture - Day 135 ---Efficient Workflows and Security Practices: watch duringsecurity/production hardening - Prometheus/Grafana InterviewReadiness: watch during the monitoring/SRE stage - Day 189 ---Shopping site with Kubernetes + AI/ML Integration: later/supportingcontent, not a core priority

Core Principle

The project is the spine of the roadmap.

Build → learn the required concept/tool → implement → troubleshoot →revise → move to the next layer.

Do not treat revision, new concepts, Scaler recordings and projects asfour separate full-time tracks.
