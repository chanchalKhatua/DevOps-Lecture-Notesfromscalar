# 🚀 AWS ECS + ECR Hands-on (Advanced Structured Notes)

Below is the structured, interview-ready Markdown version of your notes, optimized for quick scanning and clarity.

---

## 1️⃣ ECR Lifecycle Policy (Image Retention: Keep Latest Only)

### 🎯 Objective
Maintain only the most recent image (`v2`) and expire older ones (`v1`).

### 🧱 Implementation Steps

**Step 1: Create Repository with Scan Enabled**
```bash
aws ecr create-repository \
  --repository-name lab-repo-<ACCOUNT_ID>-lifecycle \
  --region us-west-2 \
  --image-scanning-configuration scanOnPush=true
```

**Step 2: Define and Apply Lifecycle Policy**
Create a `policy.json` file:
```json
{
  "rules": [
    {
      "rulePriority": 1,
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

> **🔍 Key Insight:** This policy keeps the latest 1 image and deletes older images based on the **push timestamp**, not the tag name.

Apply the policy:
```bash
aws ecr put-lifecycle-policy \
  --repository-name lab-repo-<ACCOUNT_ID>-lifecycle \
  --lifecycle-policy-text file://policy.json \
  --region us-west-2
```

**Step 3: Build & Push (Requires Sudo)**
```bash
# Login (token valid 12h)
aws ecr get-login-password --region us-west-2 | sudo docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com

# Build and Push v1
sudo docker build -t lab-repo-<ACCOUNT_ID>-lifecycle .
sudo docker tag lab-repo-<ACCOUNT_ID>-lifecycle:latest <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lab-repo-<ACCOUNT_ID>-lifecycle:v1
sudo docker push <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lab-repo-<ACCOUNT_ID>-lifecycle:v1

# Modify code, then Build and Push v2
sudo docker build -t lab-repo-<ACCOUNT_ID>-lifecycle .
sudo docker tag lab-repo-<ACCOUNT_ID>-lifecycle:latest <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lab-repo-<ACCOUNT_ID>-lifecycle:v2
sudo docker push <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lab-repo-<ACCOUNT_ID>-lifecycle:v2
```

**Step 4: Preview Lifecycle Execution**
```bash
aws ecr start-lifecycle-policy-preview \
  --repository-name lab-repo-<ACCOUNT_ID>-lifecycle \
  --region us-west-2

aws ecr get-lifecycle-policy-preview \
  --repository-name lab-repo-<ACCOUNT_ID>-lifecycle \
  --region us-west-2 \
  --query 'previewResults[].imageTags'
```

### ✅ Expected Outcome & Advanced Notes
* **Result:** `v1` appears marked for deletion; `v2` is retained.
* **Delay:** Deletion is not immediate (can take ~24h).
* **Preview:** A preview is not an actual deletion. Always test lifecycle rules before applying them to production.

---

## 2️⃣ ECS Fargate Deployment (Basic Flask Service)

### 🎯 Architecture Flow
**ECR** → **ECS Task** → **Fargate** → **ENI** → **Public IP** → **Internet**

### 🧱 Implementation Steps

**Step 1: Push Flask Image**
```bash
docker build -t lab-ecs-repo-<ACCOUNT_ID>-flask .
docker tag lab-ecs-repo-<ACCOUNT_ID>-flask:latest <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lab-ecs-repo-<ACCOUNT_ID>-flask:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lab-ecs-repo-<ACCOUNT_ID>-flask:latest
```

**Step 2: Create IAM Execution Role & CloudWatch Group**
* **Role Name:** `ecsTaskExecutionRole`
* **Policy:** `AmazonECSTaskExecutionRolePolicy`
* **Critical Usage:** Required for ECR pulls and sending CloudWatch logs.

```bash
aws logs create-log-group \
  --log-group-name /ecs/flask-task-def \
  --region us-west-2
```

**Step 3: Network & Security Group**
| Port | Source | Protocol |
| :--- | :--- | :--- |
| 80 | 0.0.0.0/0 | TCP |

**Step 4: Task Definition Configuration**
Create a `flask-task-def.json` file:
```json
{
  "family": "flask-task-def",
  "networkMode": "awsvpc",
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::<ACCOUNT_ID>:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "flask",
      "image": "<ECR_URI>",
      "portMappings": [{ "containerPort": 80 }],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/flask-task-def",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "flask"
        }
      }
    }
  ]
}
```

**Step 5: Register and Deploy**
```bash
# Register Task
aws ecs register-task-definition --cli-input-json file://flask-task-def.json --region us-west-2

# Create Cluster
aws ecs create-cluster --cluster-name flask-cluster

# Create Service
aws ecs create-service \
  --cluster flask-cluster \
  --service-name flask-service \
  --task-definition flask-task-def \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
```

> **⚠️ Advanced Notes:** Using `awsvpc` network mode means each task gets a dedicated ENI. Public access requires a Public Subnet, an Internet Gateway (IGW), and `assignPublicIp=ENABLED`.

---

## 3️⃣ ECS with Environment Variables (Dynamic Response)

### 🎯 Objective
Return a dynamic value injected via the `MY_MESSAGE` environment variable at container runtime, avoiding image rebuilds.

### 🧱 Task Definition Delta
```json
{
  "name": "flask-env",
  "environment": [
    { "name": "MY_MESSAGE", "value": "Hello from ENV!" }
  ]
}
```

### ⚠️ Production Upgrade Paths
| Method | Best Use Case |
| :--- | :--- |
| **env** | Simple, non-sensitive configuration |
| **SSM Parameter Store** | Secure and dynamic configuration |
| **Secrets Manager** | High security and automatic credential rotation |

---

## 4️⃣ ECS End-to-End (Full Production Flow)

### 🎯 Flow Summary
**Code** → **Docker** → **ECR** → **ECS Task** → **ECS Service** → **Internet**

### 🔥 Critical Design Concepts

1.  **Stateless Containers:** No local storage dependency, which is mandatory for horizontal scaling.
2.  **Deployment Behavior:** Zero-downtime rolling replacements are managed via minimum/maximum health constraints.
    ```json
    "deploymentConfiguration": {
      "maximumPercent": 200,
      "minimumHealthyPercent": 100
    }
    ```
3.  **Logging Pipeline:** Container `stdout` → `awslogs` driver → CloudWatch.
4.  **Networking Model:** Task → ENI → Security Group → Internet.

### 🧩 Component Comparisons

**Task vs. Service**
| Component | Primary Purpose |
| :--- | :--- |
| **Task** | Single-run execution (batch jobs, cron tasks). |
| **Service** | Long-running processes with auto-healing and desired count maintenance. |

**IAM Roles**
| Role | Purpose |
| :--- | :--- |
| **executionRole** | ECS agent operations (pulling images, sending logs to CloudWatch). |
| **taskRole** | Application-level AWS access (e.g., app accessing S3 or DynamoDB). |

### ⚡ Common Failure Debugging (High Value)

| Issue | Potential Root Causes |
| :--- | :--- |
| **CannotPullContainerError** | Missing IAM permissions, expired ECR login token. |
| **Task Not Starting** | CPU/Memory limits mismatch, no IP addresses available in subnet. |
| **App Not Accessible** | Security group blocking traffic, missing public IP, wrong subnet route table. |

### 🧠 Interview Power Points

* **Why Fargate?** Zero infrastructure management, pay-per-usage, and strong container isolation.
* **Why ECR?** Natively integrated with AWS IAM, secure/private hosting, and automated lifecycle policies.
* **Lifecycle Policy Trick Question:** Deletion is triggered by the **push time**, not the image tag name.
* **Real Production Improvements:** Always opt for an ALB instead of exposing Public IPs directly. Use Private Subnets with a NAT Gateway, Auto Scaling, robust Health Checks, and a proper CI/CD pipeline.

### ✅ Final Mental Model
1.  **ECR** (Image Storage)
2.  **Task Definition** (Blueprint)
3.  **ECS Service** (Orchestrator)
4.  **Fargate** (Compute engine)
5.  **ENI + SG** (Networking boundary)
6.  **CloudWatch** (Observability & Logs)
