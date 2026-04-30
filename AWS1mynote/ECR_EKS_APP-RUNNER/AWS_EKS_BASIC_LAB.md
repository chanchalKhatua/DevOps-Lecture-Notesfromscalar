# AWS EKS Advanced Lab Guide - Interview Ready Notes

## 🎯 Overview: Scenario-Based EKS Patterns

This guide extracts **unique, advanced concepts** from 4 EKS lab scenarios, excluding repetitive setup steps. Focus on deployment strategies, troubleshooting, and interview-ready insights.

---

## 📋 Common Foundation (Reference Only)

<details>
<summary>Standard EKS Setup Pattern (Click to expand)</summary>

### IAM Roles Required
- **EKSClusterRole**: 5 managed policies (Cluster, Networking, BlockStorage, Compute, LoadBalancing)
- **EKSNodeRole**: 4 managed policies (ECR Pull/Read, CNI, WorkerNode)

### Cluster Specs
- Region: `us-west-2`
- Naming: `lab-eks-<ACCOUNT_ID>`
- Network: Default VPC, public access
- Add-ons: VPC CNI, kube-proxy

### Node Group
- Type: `t3.micro` (cost-efficient)
- Scaling: Min=1, Desired=2, Max=3

</details>

---

## 🚀 Scenario 1: NGINX Deployment & LoadBalancer Service

### **Use Case**: Developer Sandbox / Basic Service Exposure

### Unique Concepts

#### 1. **Deployment Manifest Deep Dive**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1  # Single replica for testing
  selector:
    matchLabels:
      app: nginx  # Must match template labels
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25  # Specific version pinning
        ports:
        - containerPort: 80  # Container listens on 80
```

**Interview Points**:
- **Q**: Why pin `nginx:1.25` instead of `latest`?
  - **A**: Ensures reproducibility; `latest` tag can change unexpectedly, breaking deployments
- **Q**: What happens if `selector.matchLabels` doesn't match `template.metadata.labels`?
  - **A**: Deployment controller won't manage pods → zero pods created

#### 2. **LoadBalancer Service Architecture**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer  # AWS ELB integration
  selector:
    app: nginx  # Routes to pods with this label
  ports:
  - port: 80        # External port
    targetPort: 80  # Container port
```

**Advanced Interview Topics**:

| Component | AWS Resource | Interview Question |
|-----------|-------------|-------------------|
| `type: LoadBalancer` | Classic ELB (default) | How to use NLB instead? |
| External IP | ELB DNS name | Why DNS instead of static IP? |
| Health checks | ELB → Target Group | What happens if pods fail health checks? |

**Answers**:
1. **Use NLB**: Add annotation `service.beta.kubernetes.io/aws-load-balancer-type: "nlb"`
2. **DNS vs IP**: AWS Load Balancers use DNS for HA across AZs; IP can change during replacements
3. **Failed health checks**: ELB removes pod from rotation; Kubernetes recreates pod via ReplicaSet

#### 3. **Validation Commands**

```bash
# Check service provisioning
kubectl get svc nginx-service

# Expected output:
# NAME            TYPE           EXTERNAL-IP                         PORT(S)
# nginx-service   LoadBalancer   a1b2c3...elb.amazonaws.com          80:31234/TCP

# Test external access
curl http://<EXTERNAL-IP>
```

**Troubleshooting Scenarios**:

| Issue | Cause | Solution |
|-------|-------|----------|
| External IP shows `<pending>` | ELB creation in progress | Wait 2-5 min; check AWS console |
| `Connection refused` | Security group blocks port 80 | Verify node security group allows ingress |
| `503 Service Unavailable` | No healthy targets | Check pod status: `kubectl get pods` |

---

## 🐍 Scenario 2: Flask Application with Environment Variables

### **Use Case**: Debugging Production Issues / Environment Configuration

### Unique Concepts

#### 1. **Environment Variable Injection**

```yaml
spec:
  containers:
  - name: flask
    image: tiangolo/uwsgi-nginx-flask:python3.8
    env:
    - name: MY_MESSAGE
      value: "Hello from EKS!"  # Hardcoded value
    ports:
    - containerPort: 80
```

**Advanced Interview Topics**:

**Q**: How would you inject secrets instead of plaintext values?

```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-credentials
      key: password
```

**Q**: What's the difference between `env` and `envFrom`?

| Method | Use Case | Example |
|--------|----------|---------|
| `env` | Individual variables | API keys, feature flags |
| `envFrom` | Bulk import | ConfigMap with 20+ vars |

```yaml
envFrom:
- configMapRef:
    name: app-config
- secretRef:
    name: app-secrets
```

#### 2. **Multi-Container Image Pattern**

The `tiangolo/uwsgi-nginx-flask` image combines:
- **uWSGI**: WSGI server (application server)
- **NGINX**: Reverse proxy (web server)
- **Flask**: Python framework

**Interview Question**: Why this architecture instead of standalone Flask?

| Architecture | Production-Ready? | Reason |
|--------------|-------------------|--------|
| `flask run` | ❌ No | Single-threaded, development server |
| `uwsgi + nginx` | ✅ Yes | Multi-worker, handles static files, production-grade |

#### 3. **Debugging Workflow**

```bash
# Check pod logs for Flask output
kubectl logs deployment/flask-deployment

# Exec into container for debugging
kubectl exec -it deployment/flask-deployment -- /bin/bash

# Inside container, check env vars
env | grep MY_MESSAGE

# Test internal connectivity
curl localhost:80
```

**Advanced Troubleshooting**:

```bash
# Check pod events for image pull issues
kubectl describe pod <pod-name>

# Verify environment variable injection
kubectl exec deployment/flask-deployment -- env

# Test service DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup flask-service
```

---

## 🔄 Scenario 3: NGINX Rollback & Version Management

### **Use Case**: Compliance Audits / Controlled Deployment Practices

### Unique Concepts

#### 1. **Declarative vs Imperative Updates**

**Declarative** (Recommended for production):
```bash
# Modify YAML file
image: nginx:1.21 → nginx:1.23

# Apply changes
kubectl apply -f nginx-deployment.yaml
```

**Imperative** (Quick testing):
```bash
# Direct image update
kubectl set image deployment/nginx-deployment nginx=nginx:1.23
```

**Interview Question**: Which approach should you use in CI/CD pipelines?

| Method | CI/CD Usage | Reason |
|--------|-------------|--------|
| Declarative | ✅ Preferred | Git-trackable, reviewable, auditable |
| Imperative | ⚠️ Avoid | No source control, hard to reproduce |

#### 2. **Rollout History & Management**

```bash
# View deployment history
kubectl rollout history deployment/nginx-deployment

# Output:
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         kubectl set image deployment/nginx-deployment nginx=nginx:1.23

# Check rollout status
kubectl rollout status deployment/nginx-deployment
```

**Adding Change Annotations**:
```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.23 \
  --record  # Deprecated but useful for tracking
```

Better approach (modern):
```yaml
metadata:
  annotations:
    kubernetes.io/change-cause: "Update to nginx 1.23 for security patch CVE-2023-XXXX"
```

#### 3. **Rollback Strategies**

**Simple Rollback** (to previous version):
```bash
kubectl rollout undo deployment/nginx-deployment
```

**Targeted Rollback** (to specific revision):
```bash
# Rollback to revision 1
kubectl rollout undo deployment/nginx-deployment --to-revision=1
```

**Advanced Interview Topics**:

**Q**: What happens during a rollback?

1. **ReplicaSet Switch**: Deployment controller scales down new ReplicaSet, scales up old ReplicaSet
2. **Pod Recreation**: Old pods recreated with previous image
3. **Service Continuity**: LoadBalancer routes to both old and new pods during transition

**Q**: How to prevent automatic rollback on failure?

```yaml
spec:
  progressDeadlineSeconds: 600  # Rollout fails after 10 min
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Max 1 extra pod during update
      maxUnavailable: 0  # Zero downtime guarantee
```

#### 4. **Verification Commands**

```bash
# Check current image version
kubectl get deployment nginx-deployment -o jsonpath='{.spec.template.spec.containers[0].image}'

# Verify pods are running correct version
kubectl get pods -o jsonpath='{.items[*].spec.containers[0].image}'

# Check ReplicaSets (shows old and new)
kubectl get rs -l app=nginx
```

**Advanced Validation**:
```bash
# Describe deployment to see rollout events
kubectl describe deployment nginx-deployment | grep -A 10 "Events:"

# Check revision annotations
kubectl get rs -l app=nginx -o yaml | grep -A 5 "deployment.kubernetes.io/revision"
```

---

## 🎓 Advanced Interview Topics

### 1. **EKS Networking Deep Dive**

#### VPC CNI Plugin Behavior

```bash
# Check CNI configuration
kubectl get daemonset aws-node -n kube-system -o yaml
```

**Interview Questions**:

**Q**: Why does each pod get an ENI IP from the VPC?

| Traditional K8s | AWS VPC CNI | Implication |
|-----------------|-------------|-------------|
| Overlay network (10.x.x.x) | Direct VPC IPs | Pods directly accessible from VPC resources |
| NAT for external access | Security groups on pods | Fine-grained network control |

**Q**: What's the max pods per node?

**Formula**: `(ENIs per instance × IPs per ENI) - 1`

Example for `t3.micro`:
- 2 ENIs × 2 IPs = 4 IPs
- 4 - 1 (reserved for node) = **3 pods max**

### 2. **IAM Roles for Service Accounts (IRSA)**

**Problem**: Pods shouldn't use node IAM role (over-privileged)

**Solution**: IRSA

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-reader
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/S3ReadOnlyRole
---
spec:
  serviceAccountName: s3-reader  # Pod uses this SA
```

**Interview Question**: How does IRSA work under the hood?

1. **OIDC Provider**: EKS creates OIDC endpoint
2. **Trust Policy**: IAM role trusts OIDC provider
3. **Token Projection**: Kubernetes injects JWT token into pod
4. **AWS SDK**: Reads token from `/var/run/secrets/eks.amazonaws.com/serviceaccount/token`

### 3. **LoadBalancer vs Ingress**

| Aspect | LoadBalancer Service | Ingress + ALB |
|--------|---------------------|---------------|
| AWS Resource | 1 ELB per service | 1 ALB for multiple services |
| Cost | High (many ELBs) | Low (shared ALB) |
| Path-based routing | ❌ No | ✅ Yes (`/api`, `/web`) |
| TLS termination | Manual | Automatic (ACM integration) |

**When to use what**:
- **LoadBalancer**: Quick tests, single-service apps
- **Ingress**: Production multi-service apps

### 4. **Cluster Autoscaler vs Karpenter**

**Cluster Autoscaler** (Traditional):
```yaml
# Scales existing node groups
# Limitations: Pre-defined instance types, slower
```

**Karpenter** (Modern, AWS-native):
```yaml
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot", "on-demand"]  # Mix spot + on-demand
```

**Interview Answer**: Karpenter provisions nodes in **seconds** vs minutes, supports mixed instance types, and better bin-packing.

---

## 🛠️ Production Best Practices

### 1. **Resource Limits & Requests**

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"    # 0.25 CPU
  limits:
    memory: "128Mi"
    cpu: "500m"
```

**Why this matters**:
- **Requests**: Scheduler guarantees resources
- **Limits**: Prevents pod from consuming all node resources
- **OOMKilled**: If pod exceeds memory limit, Kubernetes kills it

### 2. **Liveness & Readiness Probes**

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 80
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 5
```

| Probe Type | Purpose | Failure Action |
|------------|---------|----------------|
| Liveness | Is app alive? | Restart container |
| Readiness | Can app serve traffic? | Remove from service endpoints |

### 3. **Pod Disruption Budgets**

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  minAvailable: 1  # Always keep 1 pod running
  selector:
    matchLabels:
      app: nginx
```

**Use case**: Prevents node drain from taking down all replicas during maintenance.

---

## 🔍 Troubleshooting Cheat Sheet

### Common Issues & Solutions

| Symptom | Diagnosis Command | Likely Cause | Fix |
|---------|------------------|--------------|-----|
| Pod in `Pending` state | `kubectl describe pod <name>` | Insufficient resources | Scale node group or check taints |
| `ImagePullBackOff` | `kubectl logs <pod>` | Wrong image name/tag | Verify ECR permissions or image exists |
| Service `<pending>` | `kubectl get events` | ELB creation failed | Check AWS service quotas or subnet config |
| `CrashLoopBackOff` | `kubectl logs <pod> --previous` | Application error | Check app logs, fix code |
| Nodes `NotReady` | `kubectl get nodes` | VPC CNI issue | Restart `aws-node` daemonset |

### Advanced Debugging

```bash
# Get all resources in namespace
kubectl get all -n default

# Check pod resource usage
kubectl top pods

# Trace service to pod routing
kubectl get endpoints nginx-service

# Check node capacity
kubectl describe node <node-name> | grep -A 5 "Allocated resources"

# View cluster events
kubectl get events --sort-by='.lastTimestamp'
```

---

## 📚 Interview Preparation Checklist

### Must-Know Commands

```bash
# Cluster info
aws eks describe-cluster --name lab-eks-<ACCOUNT_ID> --region us-west-2

# Update kubeconfig
aws eks update-kubeconfig --region us-west-2 --name lab-eks-<ACCOUNT_ID>

# Check cluster version
kubectl version --short

# View all namespaces
kubectl get namespaces

# Switch namespace context
kubectl config set-context --current --namespace=<namespace>

# Dry-run deployments
kubectl apply -f deployment.yaml --dry-run=client

# Explain resource specs
kubectl explain deployment.spec.strategy
```

### Critical Concepts to Master

1. **Pod Lifecycle**: Pending → Running → Succeeded/Failed
2. **Service Discovery**: ClusterIP (internal) → NodePort → LoadBalancer → Ingress
3. **ConfigMaps vs Secrets**: Plain text vs base64-encoded
4. **StatefulSets vs Deployments**: Ordered deployment, stable network identities
5. **DaemonSets**: One pod per node (monitoring, logging)
6. **Jobs vs CronJobs**: One-time tasks vs scheduled tasks
7. **Horizontal Pod Autoscaler**: CPU/memory-based scaling
8. **Network Policies**: Firewall rules between pods

---

## 🎯 Final Exam Questions

### Question 1: Architecture Design
**Scenario**: Deploy a 3-tier app (frontend, API, database) on EKS.

**Expected Answer**:
- Frontend: Deployment + Ingress (ALB with path `/`)
- API: Deployment + ClusterIP Service (internal only)
- Database: StatefulSet + Headless Service (stable pod identities)
- Secrets: Use AWS Secrets Manager + External Secrets Operator
- Storage: EBS volumes via PersistentVolumeClaims

### Question 2: Disaster Recovery
**Q**: EKS cluster deleted accidentally. How to restore?

**Answer**:
1. Recreate cluster with same name/region
2. Restore node groups
3. Re-apply all manifests from Git repository (GitOps)
4. Restore persistent data from EBS snapshots
5. Update DNS records if ELB IPs changed

### Question 3: Cost Optimization
**Q**: Reduce EKS costs by 40% without compromising reliability.

**Answer**:
1. Use **Spot Instances** for stateless workloads (60-90% savings)
2. **Karpenter** for right-sizing (vs fixed node groups)
3. **Fargate** for batch jobs (pay per pod runtime)
4. **Horizontal Pod Autoscaler** to scale down during off-peak
5. **Storage optimization**: Use gp3 instead of gp2 EBS volumes

---

This advanced guide focuses on differentiation, depth, and interview readiness—eliminating repetitive setup steps while maximizing learning value. Master these concepts to excel in EKS/Kubernetes interviews! 🚀
