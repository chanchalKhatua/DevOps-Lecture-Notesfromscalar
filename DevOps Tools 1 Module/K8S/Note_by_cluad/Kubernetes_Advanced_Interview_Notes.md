# Kubernetes Core Concepts - Advanced Interview Ready Notes

**Last Updated:** March 2026  
**Target Audience:** Advanced learners, Interview candidates, DevOps professionals  
**Difficulty Level:** Intermediate to Advanced

---

## Table of Contents

1. [Introduction & Evolution](#introduction--evolution)
2. [Why Kubernetes - The Problem Statement](#why-kubernetes---the-problem-statement)
3. [Kubernetes Architecture Deep Dive](#kubernetes-architecture-deep-dive)
4. [Control Plane Components](#control-plane-components)
5. [Worker Node Components](#worker-node-components)
6. [Core Concepts](#core-concepts)
7. [Types of Kubernetes Setups](#types-of-kubernetes-setups)
8. [kubeconfig & Context Management](#kubeconfig--context-management)
9. [Interview Preparation & FAQs](#interview-preparation--faqs)

---

## Introduction & Evolution

### What is Kubernetes (K8s)?

**Kubernetes** is derived from "KUBERNETES" - K + 8 letters + S, hence **K8s**.

It is a **container orchestration platform** that automates the deployment, scaling, and operation of containerized applications across clusters of machines.

### Evolution of Deployment Strategies

#### 1. **Physical Machines Era**
- **Model**: One application per physical machine
- **Pros**: Complete resource isolation
- **Cons**: Massive cost, poor resource utilization, inflexible
- **Example**: Running a single database on one $10,000 server

#### 2. **Virtual Machines (VM) Era**
- **Model**: Multiple isolated applications per physical machine
- **Pros**: Better resource utilization, cost reduction
- **Cons**: VM overhead, slower startup times
- **Example**: Hypervisors (VMware, Hyper-V) running multiple VMs on a single host

#### 3. **Containers Era**
- **Model**: Lightweight, isolated containers running multiple applications per VM/Physical machine
- **Pros**: Extreme efficiency, fast startup (milliseconds), consistent environments
- **Cons**: Complex orchestration when scaling to thousands of containers
- **Example**: Docker containers, but manual orchestration becomes nightmare at scale

#### 4. **Kubernetes Era** (The Current Standard)
- **Model**: Automated orchestration of containerized applications
- **Pros**: Automatic scaling, self-healing, load balancing, zero-downtime deployments
- **Cons**: Learning curve, operational complexity

### The Scaling Problem Without Kubernetes

**Real-world Example: E-commerce Platform During Black Friday**

```
Service: Add to Cart
- Normal load: 100 containers
- Black Friday peak: 1000 containers needed
- Manual Process:
  ✗ Monitor metrics every minute
  ✗ SSH into VMs, launch new containers
  ✗ Manually configure load balancers
  ✗ Update routing rules
  ✗ Manage resource allocation
  ✗ Handle failed containers manually
  ✗ Time to scale: 30-60 minutes
  ✗ Error-prone human interventions

Service: Review Cart
- Normal: 100 containers
- Black Friday: 10 containers only needed
- But you've allocated resources for 100 containers → wasted money

Service: Place Order
- Variable load: 10-1000 containers
- Requires complex scheduling logic
```

**The Solution**: Kubernetes automates all of this ✅

---

## Why Kubernetes - The Problem Statement

### 1. **Central Controller (Control Plane)**
**Problem**: Who decides where containers run?  
**Solution**: Kubernetes Control Plane acts as the brain of the cluster
- Makes intelligent scheduling decisions
- Maintains desired state
- Enforces policies and quotas
- Provides centralized management through API

**Interview Angle**:
- API server is stateless
- Scheduler and controller manager are stateless but operate based on state stored in etcd
- etcd acts as the single source of truth for the entire cluster

Result:
This architecture enables horizontal scaling of control plane components and high availability.

### 2. **Scalability (Horizontal Scaling)**
**Problem**: How do we add more container capacity quickly?  
**Solution**: 
- Add more worker nodes to the cluster
- Kubernetes automatically distributes workloads
- Linear scalability with cluster size
- Auto-scaling based on metrics

**Interview Angle**: "Kubernetes can handle clusters with thousands of nodes, with load-aware scheduling preventing bottlenecks."

### 3. **Cost Efficiency (Scale-In)**
**Problem**: How do we avoid paying for unused resources?  
**Solution**:
- Remove nodes when demand decreases
- Gracefully drain pods from nodes being decommissioned
- Pod priority and preemption for cost optimization
- Cloud integration for automatic provisioning

**Interview Angle**: "Kubernetes Cluster Autoscaler uses node utilization metrics to make scale-in/out decisions, typically saving 30-40% on cloud costs."

### 4. **Health Monitoring & Self-Healing**
**Problem**: Containers crash; how do we handle them automatically?  
**Solution**:
- **Liveness Probes**: Restart unhealthy containers
- **Readiness Probes**: Remove unhealthy pods from load balancing
- **Startup Probes**: Handle slow-starting applications
- **Node Health Monitoring**: Evict pods from failed nodes

**Interview Angle**: "Kubelet's health monitoring is configurable with initialDelaySeconds, periodSeconds, and timeoutSeconds—critical for production reliability."

### 5. **Portability (Cloud Agnosticism)**
**Problem**: Vendor lock-in; can we run on any cloud?  
**Solution**:
- Kubernetes works on AWS (EKS), Azure (AKS), GCP (GKE), on-premises, edge
- Same YAML manifests across environments
- Cloud-agnostic networking and storage abstractions
- Multi-cloud and hybrid deployments

**Interview Angle**: "Cloud Controller Manager integrates with cloud providers, but core K8s remains vendor-neutral—you can migrate workloads between clouds with minimal changes."

---

## Kubernetes Architecture Deep Dive

### High-Level Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         KUBERNETES CLUSTER                   │
├──────────────────────────────┬──────────────────────────────┤
│                              │                              │
│      CONTROL PLANE           │      WORKER NODES            │
│      (Master Node)           │      (Worker Nodes)          │
│                              │                              │
│  ┌─────────────────────┐    │  ┌──────────────────────┐   │
│  │  kube-apiserver     │    │  │  Node 1              │   │
│  │  (Port 6443)        │    │  │  ┌────────────────┐  │   │
│  └──────────┬──────────┘    │  │  │ kubelet        │  │   │
│             │               │  │  │ kube-proxy     │  │   │
│  ┌──────────▼──────────┐    │  │  │ container-rt   │  │   │
│  │  kube-scheduler     │    │  │  │ ┌────────────┐ │  │   │
│  └─────────────────────┘    │  │  │ │   Pod-1    │ │  │   │
│                              │  │  │ │   Pod-2    │ │  │   │
│  ┌─────────────────────┐    │  │  │ │   Pod-N    │ │  │   │
│  │  kube-controller    │    │  │  │ └────────────┘ │  │   │
│  │  -manager           │    │  │  └────────────────┘  │   │
│  └─────────────────────┘    │  └──────────────────────┘   │
│                              │                              │
│  ┌─────────────────────┐    │  ┌──────────────────────┐   │
│  │  cloud-controller   │    │  │  Node 2              │   │
│  │  -manager           │    │  │  (Similar structure) │   │
│  └─────────────────────┘    │  └──────────────────────┘   │
│                              │                              │
│  ┌─────────────────────┐    │  ┌──────────────────────┐   │
│  │  etcd               │    │  │  Node N              │   │
│  │  (Data Store)       │    │  │  (Similar structure) │   │
│  └─────────────────────┘    │  └──────────────────────┘   │
│                              │                              │
└──────────────────────────────┴──────────────────────────────┘
                    ▲
                    │
                    ▼
        ┌──────────────────────┐
        │  Cloud Provider API  │
        │  (AWS, Azure, GCP)   │
        └──────────────────────┘
```

### Cluster Topology Options

#### **High Availability Control Plane (Production)**
```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Master-1    │  │ Master-2    │  │ Master-3    │
│ (etcd)      │  │ (etcd)      │  │ (etcd)      │
│ API Server  │  │ API Server  │  │ API Server  │
│ Scheduler   │  │ Scheduler   │  │ Scheduler   │
│ Ctrl Mgr    │  │ Ctrl Mgr    │  │ Ctrl Mgr    │
└─────────────┘  └─────────────┘  └─────────────┘
       │                │                │
       └────────────────┼────────────────┘
                        │
            ┌───────────┴───────────┐
            │                       │
        ┌───────┐             ┌───────┐
        │Worker │ ... (Many) │Worker │
        └───────┘             └───────┘
```

#### **Single Control Plane (Development)**
```
┌─────────────────────┐
│ Master Node         │
│ (etcd, API, etc)    │
└──────────┬──────────┘
           │
    ┌──────┴──────┬──────────┐
    │             │          │
┌───────┐    ┌───────┐   ┌───────┐
│Worker1│    │Worker2│   │Worker3│
└───────┘    └───────┘   └───────┘
```

---

## Control Plane Components

### 1. **kube-apiserver**

**Role**: The gateway and central management authority of Kubernetes

**Key Characteristics**:
- **Port**: 6443 (HTTPS)
- **Type**: RESTful API server
- **Stateless**: All state stored in etcd

**Core Responsibilities**:

```
API Request Flow:
┌──────────────────────────────────────────────────────────┐
│ 1. Authentication: Verify user identity                  │
│    (Certificates, OAuth2, Webhook)                       │
├──────────────────────────────────────────────────────────┤
│ 2. Authorization: Check user permissions                 │
│    (RBAC, ABAC, Webhook)                                 │
├──────────────────────────────────────────────────────────┤
│ 3. Admission Control: Policy enforcement                 │
│    (ValidatingWebhooks, MutatingWebhooks)                │
├──────────────────────────────────────────────────────────┤
│ 4. Validation: Check YAML/JSON schema compliance         │
├──────────────────────────────────────────────────────────┤
│ 5. Storage: Store validated resource in etcd             │
├──────────────────────────────────────────────────────────┤
│ 6. Response: Return to client                            │
└──────────────────────────────────────────────────────────┘
```

**Interview Questions**:
- Q: "Can the API server be stateless?"  
  A: "Yes. All state is stored in etcd. Multiple API server instances can run behind a load balancer."

- Q: "What happens if someone bypasses authentication?"  
  A: "The admission controller and authorization layers provide defense-in-depth. Also, TLS certificates and RBAC policies ensure security."

---

### 2. **kube-scheduler**

**Role**: Intelligent pod placement engine

**How It Works**:
```
Pod Scheduling Pipeline:
┌─────────────────────────────┐
│ Unscheduled Pod Created     │
└────────────┬────────────────┘
             │
┌────────────▼────────────────┐
│ Filtering Phase             │
│ - Node status check         │
│ - Resource availability     │
│ - Label/Taint matching      │
│ Result: "Feasible Nodes"    │
└────────────┬────────────────┘
             │
┌────────────▼────────────────────────────┐
│ Scoring Phase (Plugin Framework)        │
│ - ImageLocality: Image on node?         │
│ - TaintToleration: Can pod tolerate?    │
│ - NodeAffinity: Pod preferences?        │
│ - PodAffinity: Co-location with others? │
│ - LeastRequested: Spread load?          │
│ - NodeResourcesFit: Resource fit?       │
│ Result: Best node with highest score    │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────┐
│ Pod Bound to Node           │
│ Kubelet on node gets update │
└─────────────────────────────┘
```

**Key Concepts**:

- **Predicates (Filters)**: Must-have requirements
  - PodFitsResources: Enough CPU/memory?
  - HostName: Specific node requested?
  - PodFitsHostPorts: Port conflicts?

- **Priorities (Scoring)**: Nice-to-have preferences
  - LeastRequested: Balance cluster utilization
  - BalancedResourceAllocation: Avoid hot nodes
  - ImageLocality: Prefer nodes with cached images

- **Scheduling Directives**:
  - **nodeSelector**: Simple label matching
  - **nodeAffinity**: Complex label matching (in/not in)
  - **podAffinity**: Co-locate pods
  - **podAntiAffinity**: Spread pods apart (HA)
  - **Taints & Tolerations**: Prevent scheduling (noSchedule, noExecute)

**Interview Questions**:
- Q: "Can two pods with podAntiAffinity still be scheduled on the same node?"  
  A: "No. If you define `podAntiAffinity` with `requiredDuringSchedulingIgnoredDuringExecution`, they won't be on the same node. With 'preferred', there's soft enforcement."

- Q: "What happens if a pod can't be scheduled?"  
  A: "Pod enters Pending state. Check `kubectl describe pod` for conditions (Unschedulable, FailedScheduling). Common causes: insufficient resources, node selectors, taints."

---

### 3. **kube-controller-manager**

**Role**: Runs multiple controllers ensuring desired state is maintained

**Key Controllers**:

#### **Node Controller**
```
Responsibilities:
1. Monitors node health via heartbeats (kubelet → API server)
2. Detects unresponsive nodes (NodeNotReady condition)
3. Evicts pods from failed nodes after grace period
4. Updates node status (Ready, MemoryPressure, DiskPressure)

Timeline:
┌─────────────┐
│ Node goes   │
│ offline     │
└──────┬──────┘
       │
       │ (node-monitor-grace-period: 40s)
       │
┌──────▼──────────────────────┐
│ Node marked NotReady         │
│ Pods still scheduled         │
└──────┬───────────────────────┘
       │
       │ (pod-eviction-timeout: 5m)
       │
┌──────▼──────────────────────┐
│ Pods evicted (terminated)    │
│ Rescheduled on healthy nodes │
└──────────────────────────────┘
```

#### **Replication Controller**
```
Purpose: Ensure N replicas running
Implementation: Watches Pods, matches labels
Action:
  - Current replicas < desired: Create pods
  - Current replicas > desired: Delete pods
  
IMPORTANT: Largely superseded by ReplicaSets
(ReplicaSets have better label selectors)
```

#### **Endpoint Controller**
```
Function: Maintains Endpoints object
Purpose: Maps Service → Pod IPs
Updates when pods created/deleted:

Service (stable DNS)
    ↓ (resolves to)
Endpoints (Pod IPs)
    ↓ (routed by)
KubeProxy (iptables/IPVS rules)
    ↓ (delivers to)
Pod
```

#### **Other Critical Controllers**:
- **Service Account Controller**: Auto-creates default service accounts
- **Namespace Controller**: Cleans up resources when namespace deleted
- **PersistentVolume Controller**: Binds PVCs to PVs
- **Job Controller**: Ensures batch jobs complete successfully
- **Deployment Controller**: Manages rolling updates
- **StatefulSet Controller**: Maintains pod identity
- **DaemonSet Controller**: Ensures pod on every node

**Interview Questions**:
- Q: "If a controller crashes, what happens?"  
  A: "Other controller instances take over (when multiple managers running). If it's the only one, control loop pauses until restart."

- Q: "How does controller-manager achieve high availability?"  
  A: "Leader election via etcd. Only one controller-manager is active (leader). Others wait. On leader failure, another immediately takes over."

---

### 4. **etcd - Distributed Key-Value Store**

**Definition**: Elastic, Transient, Consistent, Distributed database

**Critical for Kubernetes**:

```
What's stored in etcd:

1. Cluster State
   - All Pods, Services, ConfigMaps, Secrets
   - All Deployments, StatefulSets, DaemonSets
   - All volumes, claims, nodes

2. Configuration
   - Resource quotas
   - Network policies
   - RBAC policies (Roles, RoleBindings)

3. Metadata
   - Labels, annotations
   - Timestamps
   - Resource versions (for conflict detection)

4. Operational
   - Leader election (for HA)
   - Lock management

Size Considerations:
- Each etcd entry: ~1KB average
- Typical cluster: 100K resources → ~100MB
- Large clusters: 1M resources → needs monitoring

Backup Strategy:
- Daily etcd snapshots (critical!)
- Example: etcdctl snapshot save backup.db
```

**etcd Architecture in HA**:

```
Setup: 3 master nodes (odd number for quorum)

┌──────────┐    ┌──────────┐    ┌──────────┐
│ Master-1 │    │ Master-2 │    │ Master-3 │
│ etcd     │◄──►│ etcd     │◄──►│ etcd     │
│ (Leader) │    │ (Follower)   │ (Follower)
└──────────┘    └──────────┘    └──────────┘

Write Flow:
1. Client → Master-1 (Leader)
2. Master-1 writes locally
3. Master-1 replicates to Master-2, Master-3
4. Quorum achieved (2 out of 3 = majority)
5. Confirms write to client

Read Flow:
1. Client → Any Master (Leader or Follower)
2. Immediate return (reads are not consensus)

Consistency Level:
- Strong consistency: Write must achieve quorum
- Eventual consistency: Reads from followers may lag
```

**Interview Questions**:
- Q: "What happens if 2 out of 3 etcd nodes fail?"  
  A: "Cluster loses quorum. No writes possible. Reads still work from remaining node but can't apply changes. Must restore failed nodes or add new masters."

- Q: "Can we scale etcd horizontally like other K8s components?"  
  A: "No. etcd cluster size is typically 3, 5, or 7 (odd for quorum). More nodes = slower consensus. Scaling beyond 7 is anti-pattern."

- Q: "How do we backup etcd?"  
  A: "Use `etcdctl snapshot save backup.db`. Schedule daily backups. Test restore procedures. Critical for disaster recovery."

---

### 5. **cloud-controller-manager**

**Role**: Interface between Kubernetes and cloud providers

**Responsibilities**:

```
Cloud-Specific Tasks:

1. Node Management
   - Discover nodes from cloud provider
   - Sync node metadata (instance IDs, regions)
   - Remove nodes deleted in cloud

2. Load Balancer Management
   - Create cloud load balancers for Service type: LoadBalancer
   - Update rules as pods come/go
   - Cloud: NLB/ALB (AWS), Load Balancer (Azure), LB (GCP)

3. Storage Management
   - Provision cloud volumes (EBS, Disk, GCE Disks)
   - Attach/detach volumes to nodes
   - Delete volumes when PVC removed

4. Route Management
   - Configure cloud routing tables
   - Enable pod-to-pod communication across nodes
   - Cloud: VPC routes (AWS), Routes (Azure), Routes (GCP)

Example (AWS EKS):
┌────────────────────────────────────────┐
│ Kubernetes Cluster                     │
│ ┌──────────────────────────────────┐  │
│ │ cloud-controller-manager (AWS)   │  │
│ │ - Manages EBS volumes            │  │
│ │ - Creates ALB/NLB for Services   │  │
│ │ - Configures VPC routes          │  │
│ └──────────────┬───────────────────┘  │
└─────────────────┼──────────────────────┘
                  │ (AWS API calls)
                  ▼
        ┌──────────────────────┐
        │ AWS APIs             │
        │ - EC2 (nodes)        │
        │ - EBS (volumes)      │
        │ - ELB/ALB (LB)       │
        │ - VPC (networking)   │
        └──────────────────────┘
```

**Interview Questions**:
- Q: "If cloud-controller-manager fails, can pods still run?"  
  A: "Yes. Existing pods run fine. New LoadBalancer services can't be created. Volume provisioning fails. It's not a critical path but needed for cloud features."

---

## Worker Node Components

### 1. **kubelet**

**Definition**: Node agent running on every worker node (and control plane nodes)

**Nature**: Not managed by Kubernetes (runs as system daemon)

**Architecture**:

```
Kubelet's Main Loop:
┌──────────────────────────────────────┐
│ Kubelet Initialization                │
│ - Load kubeconfig                    │
│ - Start container runtime            │
│ - Register node with API server      │
└────────────┬─────────────────────────┘
             │
┌────────────▼──────────────────────────────────────┐
│ Main Watch Loop (every 10-20 seconds)            │
├───────────────────────────────────────────────────┤
│ 1. Get assigned pods from API server              │
│ 2. Sync actual state with desired state:          │
│    - Create missing containers                    │
│    - Kill extra containers                        │
│    - Restart unhealthy containers                 │
│ 3. Report node status (memory, CPU, disk)         │
│ 4. Report pod status (phases, conditions)         │
│ 5. Collect metrics (via cAdvisor)                 │
└────────────┬──────────────────────────────────────┘
             │
             └──► (repeat every syncPeriod)
```

**Key Responsibilities**:

#### **Pod Lifecycle Management**
```
Kubelet receives PodSpec (YAML) from API Server

Steps:
1. Create pod sandbox (network namespace)
   └─► Pod gets IP address
2. Mount volumes
   └─► PersistentVolumes, ConfigMaps, Secrets
3. Create containers
   ├─► Pull image from registry
   ├─► Create container
   ├─► Setup security context
   └─► Start container
4. Probe container health
   ├─► Liveness probe (restart if dead)
   ├─► Readiness probe (remove from load balancing if not ready)
   └─► Startup probe (wait for app startup)
5. Monitor and manage lifecycle
   └─► Logs, metrics, status updates
```

#### **Probes in Detail**

```yaml
# Liveness Probe: Is the app alive?
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15      # Wait before first check
  periodSeconds: 20            # Check every 20s
  timeoutSeconds: 5            # Wait 5s for response
  failureThreshold: 3          # Fail after 3 consecutive failures
  # Action: Restart container
  
# Readiness Probe: Can the app handle traffic?
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
  # Action: Remove from Service endpoints if not ready

# Startup Probe: Has the app finished starting?
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  initialDelaySeconds: 0
  periodSeconds: 10
  failureThreshold: 30          # 30 * 10s = 5 min startup window
  # Action: Prevents liveness probe from restarting app during startup
```

#### **Node Status Reporting**
```
Node Conditions (kubelet reports every 10s):

1. Ready
   - True: Node is healthy, accepting pods
   - False: Node not accepting pods
   - Unknown: No heartbeat from kubelet (5 min timeout)

2. MemoryPressure
   - True: Low available memory
   - Action: Evict pods with PriorityClass

3. DiskPressure
   - True: Low available disk
   - Action: Evict pods

4. PIDPressure
   - True: Too many processes
   - Action: Evict pods

5. NetworkUnavailable
   - True: Network not ready
   - Usually set by cloud-controller-manager
```

#### **Resource Management**

```
CPU & Memory Limits:

Pod Specification:
spec:
  containers:
  - name: app
    resources:
      requests:
        cpu: "500m"          # Guaranteed 0.5 CPUs
        memory: "128Mi"      # Guaranteed 128 MB
      limits:
        cpu: "1"             # Max 1 CPU (can burst briefly)
        memory: "256Mi"      # Max 256 MB (OOMKilled if exceeded)

Kubelet Enforcement:
- Requests: Used for scheduling (can't schedule if node has insufficient requests)
- Limits: Enforced at runtime via cgroups
  - CPU: Throttling (soft limit)
  - Memory: OOMKill (hard limit)

QoS Classes (assigned by kubelet):
1. Guaranteed: requests == limits (most stable)
2. Burstable: requests < limits (can surge)
3. BestEffort: no requests/limits (can be evicted first)

Eviction Policy (when node under pressure):
1. BestEffort pods first
2. Burstable pods (worst offenders)
3. Guaranteed pods (last resort)
```

#### **Volume Management**
```
kubelet Responsibilities:

1. Mount volumes to pod
   - Local volumes (emptyDir)
   - Persistent volumes (NFS, cloud storage)
   - ConfigMaps (as files)
   - Secrets (as files)

2. Unmount on pod termination
3. Handle mount failures gracefully
4. Enforce storage permissions
```

#### **ConfigMap & Secret Injection**
```
kubelet pulls secrets/configmaps from API server:

volumeMounts:
- name: config
  mountPath: /etc/config
volumes:
- name: config
  configMap:
    name: app-config
    
or

env:
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secrets
      key: password

kubelet retrieves secret from API server 
and injects into container environment
```

**Interview Questions**:
- Q: "Can kubelet work offline?"  
  A: "Partially. If API server is unreachable, kubelet continues managing existing pods using last known state. New pods can't be scheduled. Cleanup and health checks still run."

- Q: "What happens if kubelet crashes?"  
  A: "Pods remain running (container runtime continues). Once kubelet restarts, it syncs state and resumes monitoring. Systemd/supervisor should auto-restart kubelet."

- Q: "How to prevent pod eviction for critical apps?"  
  A: "Set `PriorityClass` to 'system-cluster-critical'. Guaranteed QoS class (requests==limits). Pod disruption budgets for graceful eviction."

---

### 2. **kube-proxy**

**Definition**: Network proxy running on every node

**Responsibility**: Implement Service abstraction (load balancing)

**How It Works**:

```
Kube-Proxy Modes:

1. iptables Mode (Default, most common)
   ┌────────────────────────────────────┐
   │ Client requests Service IP         │
   │ (ClusterIP: 10.0.0.1:80)           │
   └────────────┬───────────────────────┘
                │
   ┌────────────▼───────────────────────────────┐
   │ Packet hits iptables rule installed by     │
   │ kube-proxy on destination node             │
   └────────────┬───────────────────────────────┘
                │
   ┌────────────▼───────────────────────────────┐
   │ iptables DNAT (Destination NAT)            │
   │ 10.0.0.1:80 → 10.1.1.5:8080 (Pod IP)      │
   │ 10.0.0.1:80 → 10.1.1.6:8080 (Pod IP)      │
   │ 10.0.0.1:80 → 10.1.1.7:8080 (Pod IP)      │
   │ (Random selection for load balancing)      │
   └────────────┬───────────────────────────────┘
                │
   ┌────────────▼───────────────────────────────┐
   │ Packet delivered to Pod                    │
   │ (NAT happens transparently)                │
   └────────────────────────────────────────────┘

   Limitations:
   - iptables is linear (rules scale as O(n))
   - High load can cause latency spike
   - Debugging complex with many rules

2. IPVS Mode (IP Virtual Server, better performance)
   ┌────────────────────────────────────┐
   │ Client requests Service IP         │
   │ (ClusterIP: 10.0.0.1:80)           │
   └────────────┬───────────────────────┘
                │
   ┌────────────▼───────────────────────────────┐
   │ IPVS load balancer (kernel level)          │
   │ Uses hash table (O(1) lookup)              │
   │ Much faster than iptables                  │
   │ Supports multiple algorithms:              │
   │ - Round-robin                              │
   │ - Least connections                        │
   │ - IP Hash (session persistence)            │
   └────────────┬───────────────────────────────┘
                │
   ┌────────────▼───────────────────────────────┐
   │ Packet delivered to Pod                    │
   └────────────────────────────────────────────┘

   Advantages:
   - O(1) lookup (constant time)
   - Better for large clusters
   - Better for high-traffic scenarios
   
3. userspace Mode (legacy, not recommended)
   - Packets processed in userspace (kube-proxy)
   - Very slow, only for debugging
```

**Service Endpoint Tracking**:

```
Workflow:

1. Service Created
   kind: Service
   spec:
     selector:
       app: web
     ports:
     - port: 80
       targetPort: 8080

2. Endpoint Controller watches Pods matching selector
   └─► Creates Endpoints object with matching Pod IPs

3. kube-proxy watches Endpoints
   └─► Updates local routing rules (iptables/IPVS)

4. Traffic Flow
   Client → Service IP → iptables/IPVS → Pod

5. Pod dies
   └─► Endpoints updated (removed)
   └─► kube-proxy updates rules
   └─► New traffic routes to remaining Pods
```

**Interview Questions**:
- Q: "If pod IP is 10.1.1.5 and Service IP is 10.0.0.1, how does traffic get from client to pod?"  
  A: "kube-proxy uses iptables/IPVS rules to perform DNAT. Destination address (Service IP) is rewritten to pod IP. Return traffic uses reverse NAT (SNAT)."

- Q: "Why not use Services directly for all networking?"  
  A: "Services are cluster-internal. For external traffic, use Ingress or LoadBalancer service. Services don't provide external IP routing."

---

### 3. **Container Runtime Interface (CRI)**

**Definition**: Plugin interface allowing kubelet to use multiple container runtimes

**Supported Runtimes**:

```
Popular CRI Implementations:

1. containerd (Recommended, CNCF graduated)
   - Originally Docker's container runtime
   - Now standalone, industry standard
   - Lightweight, fast startup
   - Used by GKE, EKS by default

2. CRI-O (Kubernetes-focused)
   - Minimal runtime for K8s
   - Good for air-gapped deployments
   - Less overhead than Docker/containerd

3. Docker (Legacy, via cri-dockerd)
   - Docker was originally only way to run containers
   - K8s 1.20+ removed direct Docker support
   - Now via CRI shim (cri-dockerd)
   - Deprecated, use containerd instead

4. rkt (Archived, not active)
   - Was CoreOS container runtime
   - Project archived in 2020

kubelet Configuration:
KUBELET_EXTRA_ARGS=--container-runtime=remote \
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock
```

**CRI Interface (gRPC)**:

```
Two main RPC services:

1. ImageService
   - PullImage(image_ref, auth)
   - RemoveImage(image_ref)
   - ImageStatus(image_ref)
   - ListImages()

2. RuntimeService
   - CreateContainer(config, sandbox)
   - StartContainer(container_id)
   - StopContainer(container_id, timeout)
   - RemoveContainer(container_id)
   - CreatePodSandbox(config)
   - RemovePodSandbox(sandbox_id)

Example Flow:
kubelet → CRI gRPC → containerd → OCI Runtime → Container
         (socket)              (cgroup v2, namespace setup)
```

**Interview Questions**:
- Q: "Can we switch container runtimes without recreating the cluster?"  
  A: "Technically yes, but practically difficult. Requires draining nodes, changing kubelet config, restarting kubelet. Pods stored on old runtime persist. Risky operation."

- Q: "What's the difference between CRI-O and containerd?"  
  A: "CRI-O is Kubernetes-only, minimal, lightweight. containerd is more general-purpose. Both are production-ready. CRI-O slightly lower overhead; containerd more ecosystem support."

---

## Core Concepts

### Pod - Smallest Unit of Deployment

**Definition**: A pod is a wrapper around one or more containers that share networking and storage

**Key Characteristics**:

```
Networking Model:
┌────────────────────────────┐
│ Pod (Network Namespace)     │
├────────────────────────────┤
│ localhost:8080 (container1)│
│ localhost:3000 (container2)│
│                            │
│ eth0: 10.1.1.5 (pod IP)    │
└────────────────────────────┘

All containers in pod share:
1. Network namespace (single IP, can talk via localhost)
2. IPC namespace (shared memory, message queues)
3. UTS namespace (hostname)
4. Some storage (volumes)

Containers DON'T share:
1. PID namespace (process isolation, ps can't see other container's processes)
2. File system (except volumes)
3. Resource isolation (limits apply to pod, not individual containers)
```

**Pod Lifecycle States**:

```
Pending
  └─► Pod created in etcd
      Kubelet notified, downloading image...
      
ContainerCreating
  └─► Image pulled, creating container
      Setting up volumes, network...
      
Running
  └─► At least one container running
      May have issues, but generally operational
      
Succeeded (Terminal)
  └─► All containers exited with code 0
      Pod won't restart (unless recreated)
      
Failed (Terminal)
  └─► At least one container non-zero exit
      Pod won't restart (unless recreated)
      
CrashLoopBackOff
  └─► Container keeps crashing
      Kubelet restarts with exponential backoff
      (1s, 2s, 4s, 8s... max 5min)
      
Unknown
  └─► API server lost contact with kubelet
      Unknown actual state
```

**Pod QoS Classes** (set automatically by kubelet):

```
1. Guaranteed (Highest Priority)
   - requests == limits for CPU & memory
   - Evicted last during resource pressure
   spec:
     containers:
     - resources:
         requests:
           cpu: "1"
           memory: "512Mi"
         limits:
           cpu: "1"
           memory: "512Mi"

2. Burstable (Medium Priority)
   - requests < limits OR only requests/limits defined
   - Evicted middle priority
   spec:
     containers:
     - resources:
         requests:
           cpu: "500m"
           memory: "256Mi"
         limits:
           cpu: "1"
           memory: "512Mi"

3. BestEffort (Lowest Priority)
   - No requests or limits
   - Evicted first during pressure
   spec:
     containers:
     - {} # No resources defined
```

**Pod Troubleshooting Commands**:

```bash
# Get pod status
kubectl get pods -n default

# Detailed investigation
kubectl describe pod <pod-name> -n <namespace>
# Shows: Events (why pending?), Conditions, IP, Node

# View pod logs
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -c <container-name>  # Specific container
kubectl logs -f <pod-name>  # Follow (tail -f)

# Multi-container pods (list containers)
kubectl get pods <pod-name> -o jsonpath='{.spec.containers[*].name}'

# Execute command in pod
kubectl exec <pod-name> -- <command>
kubectl exec -it <pod-name> -- /bin/bash  # Interactive shell

# Port forwarding (for debugging)
kubectl port-forward <pod-name> 8080:8080
# Now: localhost:8080 → pod:8080

# Get pod events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

**Interview Questions**:
- Q: "Can a pod have 2 containers with the same port?"  
  A: "No. They share network namespace, so port binding conflicts. Design: Use different ports and refer by container name."

- Q: "What happens if a container in a multi-container pod crashes?"  
  A: "Only that container restarts (via kubelet restart loop). Pod and other containers continue running. Pod status is still Running."

- Q: "Why use multi-container pods?"  
  A: "Tight coupling scenarios: logging sidecar, monitoring sidecar, init container. Generally use separate pods for loose coupling."

---

### Namespace - Logical Cluster Isolation

**Definition**: Virtual cluster isolation within a single physical cluster

**Built-in Namespaces**:

```
1. default
   - Default namespace for resources without explicit namespace
   - Where most users create resources

2. kube-system
   - CoreDNS, kube-proxy (DaemonSet), metrics-server, ingress controller pods
   - Contains system-level components required for cluster operation

   Runtime behavior:
   - kubelet runs as a system service on nodes (not a pod)
   - kube-proxy runs as a DaemonSet pod on each node

   Control Plane Placement:
   - In kubeadm (self-hosted clusters):
     - kube-apiserver, etcd, scheduler, controller-manager run as static pods in kube-system

   - In managed clusters (EKS/GKE/AKS):
     - Control plane is managed externally and not visible in kube-system

3. kube-public
   - Readable by all users (authenticated and unauthenticated)
   - Non-sensitive cluster information
   - ConfigMaps with public data

4. kube-node-lease
   - Heartbeat data for nodes
   - Node leases (v1.14+ HA health checking)
   - Low-level cluster coordination
```

**Creating Namespaces**:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: prod
```

```bash
kubectl create namespace staging
kubectl get namespaces
kubectl delete namespace staging  # Cascades: deletes all resources in namespace
```

**Resource Quotas** (Enforce Limits on Namespace):

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-quota
  namespace: production
spec:
  hard:
    # Pod count limits
    pods: "100"
    
    # Compute limits (aggregate)
    requests.cpu: "50"
    requests.memory: "100Gi"
    limits.cpu: "100"
    limits.memory: "200Gi"
    
    # Storage limits
    requests.storage: "500Gi"
    persistentvolumeclaims: "10"
    
    # Count limits
    services: "10"
    services.loadbalancers: "2"
    services.nodeports: "5"
    configmaps: "50"
    secrets: "50"
    replicationcontrollers: "20"
    deployments.apps: "20"
    statefulsets.apps: "5"
```

**NetworkPolicy** (Namespace-level firewall):

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}  # Applies to all pods
  policyTypes:
  - Ingress
  # No ingress rules = deny all
```

**Interview Questions**:
- Q: "Can two services in different namespaces communicate?"  
  A: "Yes. DNS: `service.namespace.svc.cluster.local`. No network isolation by default. Use NetworkPolicy for explicit isolation."

- Q: "What happens when you delete a namespace?"  
  A: "All resources in namespace deleted (graceful termination). Pods get 30s default grace period. Finalizers can extend deletion."

---

### Replica Controllers & ReplicaSets

**ReplicaSet** (Successor to ReplicationController):

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web        # Matches pods with label app=web
  template:           # Pod template
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

**Key Differences from Replication Controller**:

```
ReplicationController (Legacy):
- Supports: Equality-based selectors (app=web, tier=backend)
- Still supported but deprecated

ReplicaSet (Modern):
- Supports: Set-based selectors (in, notin, exists)
  matchLabels:
    app: web
  matchExpressions:
  - key: tier
    operator: In
    values: [frontend, backend]
- Better label selector flexibility
- Usually used via Deployment (not directly)
```

**Use Cases**:
- Ensure N replicas of a pod
- Used by Deployments internally (don't usually manage directly)
- For scaling (should use HPA instead)

**Important**: Don't use ReplicaSets directly in production. Use Deployments (which manage ReplicaSets for rolling updates).

---

### Deployment - Production Pod Management

**Definition**: High-level construct managing ReplicaSets for declarative updates

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # 1 extra pod during update
      maxUnavailable: 0  # Keep all running
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
```

**Rolling Update Strategy**:

```
Initial State: 3 pods v1.19

Update to v1.20:
Replicas=3, MaxSurge=1, MaxUnavailable=0

Step 1: Create 1 v1.20 pod (replicas=4)
        ┌─────────────────────────┐
        │ 3x v1.19 + 1x v1.20     │
        │ Ready: 3                │
        └─────────────────────────┘

Step 2: Terminate 1 v1.19 pod
        ┌─────────────────────────┐
        │ 2x v1.19 + 1x v1.20     │
        │ Ready: 3                │
        └─────────────────────────┘

Step 3: Create 1 v1.20 pod
        ┌─────────────────────────┐
        │ 2x v1.19 + 2x v1.20     │
        │ Ready: 4                │
        └─────────────────────────┘

Step 4: Terminate 1 v1.19
        ┌─────────────────────────┐
        │ 1x v1.19 + 2x v1.20     │
        │ Ready: 3                │
        └─────────────────────────┘

Step 5: Create 1 v1.20
        ┌─────────────────────────┐
        │ 1x v1.19 + 3x v1.20     │
        │ Ready: 4                │
        └─────────────────────────┘

Step 6: Terminate last v1.19
        ┌─────────────────────────┐
        │ 3x v1.20                │
        │ Ready: 3                │
        └─────────────────────────┘

Zero-downtime upgrade achieved!
```

**Revision History & Rollback**:

```bash
kubectl rollout history deployment/nginx-deploy
# Shows all revisions with reasons

kubectl rollout history deployment/nginx-deploy --revision=2
# Shows details of revision 2

kubectl rollout undo deployment/nginx-deploy
# Rollback to previous revision

kubectl rollout undo deployment/nginx-deploy --to-revision=1
# Rollback to specific revision

# Pause updates
kubectl rollout pause deployment/nginx-deploy

# Resume updates
kubectl rollout resume deployment/nginx-deploy
```

**Interview Questions**:
- Q: "If maxSurge=1 and maxUnavailable=1, what's the minimum availability during update?"  
  A: "With 3 replicas: MaxUnavailable=1 means 2 must be available. MaxSurge=1 means 4 total running. Availability: 2/3 = 66%"

- Q: "How do you perform a canary deployment?"  
  A: "Manually: Run new version alongside old (2 separate Deployments, both target Service). Or use ServiceMesh (Istio, Linkerd) for traffic splitting. Or use Flagger (progressive delivery)."

---

### Pod Disruption Budgets (PDB)

**Purpose**: Prevent too many pod disruptions during maintenance/scaling

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
spec:
  minAvailable: 2        # At least 2 pods must be running
  # OR
  maxUnavailable: 1      # Maximum 1 pod unavailable
  selector:
    matchLabels:
      app: web
```

**Use Cases**:
- Prevent Cluster Autoscaler from evicting too many pods
- Protect against human mistakes (draining nodes)
- Ensure HA for critical services

**Interview Questions**:
- Q: "If PDB says minAvailable=3 but only 2 pods running, what happens?"  
  A: "Conflicting: PDB can't be satisfied. Disruptions honored if possible but not guaranteed. Drain will hang unless --ignore-pdb flag used."

---

## Types of Kubernetes Setups

### 1. Vanilla Kubernetes

**Definition**: Upstream Kubernetes, self-managed

**Characteristics**:
- Install from source or pre-built binaries
- Full control and responsibility
- Requires operational expertise
- Best for: Organizations with strong DevOps teams

**Installation Options**:
- kubeadm: Official tool for bootstrapping (most popular)
- kubespray: Ansible-based automation
- kops: For AWS (AWS-specific)
- manual: Extreme control, not recommended

```bash
# kubeadm example (simplified)
kubeadm init --pod-network-cidr=10.244.0.0/16
# Sets up control plane on current node

kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>
# Joins worker nodes to cluster

# Install CNI plugin
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

---

### 2. Local Development Setups

#### **kind (Kubernetes IN Docker)**
```
Architecture: Each node = Docker container

Single Node:
kind create cluster --name dev
# Creates container with K8s cluster inside

Multi-Node:
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker

kind create cluster --config=multi-node.yaml --name dev

Pros:
- Fast (seconds to cluster)
- No VMs (just containers)
- Great for CI/CD
- Low resource requirements

Cons:
- Single machine (can't test network partitions)
- No cloud features (LoadBalancer, PersistentVolumes)
```

#### **minikube (Single Node Development)**
```
Runs a single-node K8s cluster in a VM or container

minikube start
# Spins up VM with K8s inside

minikube stop
# Pauses without deleting

Pros:
- Simplest for developers
- Good for learning
- Dashboard included
- Multiple hypervisors support (VirtualBox, KVM, Docker)

Cons:
- Only 1 node (can't test multi-node scenarios)
- Limited resource
- Not suited for realistic testing
```

#### **MicroK8s (Lightweight Ubuntu)**
```
Snap-based K8s for Ubuntu

snap install microk8s --classic
microk8s start

Pros:
- Very lightweight
- Latest K8s always available
- Great for edge/IoT
- Fast startup

Cons:
- Ubuntu-specific
- Limited to single node
```

---

### 3. Managed Kubernetes Services

#### **GKE (Google Kubernetes Engine)**
- Cloud provider: Google Cloud
- Control plane: Fully managed by Google
- Pricing: Pay for nodes only (control plane free)
- Advantage: Tight GCP integration

#### **EKS (Amazon Elastic Kubernetes Service)**
- Cloud provider: AWS
- Control plane: Fully managed by AWS
- Pricing: $0.10/hour per cluster + node costs
- Advantage: Native AWS integrations (IAM, RDS, S3)

#### **AKS (Azure Kubernetes Service)**
- Cloud provider: Microsoft Azure
- Control plane: Fully managed
- Pricing: Free control plane + node costs
- Advantage: Seamless Azure integrations

#### **OKE (Oracle Kubernetes Engine)**
- Cloud provider: Oracle Cloud
- Fully managed service
- Competitive pricing
- Good for existing Oracle customers

#### **OpenShift**
- Vendor: Red Hat
- Enterprise distribution of Kubernetes
- Added features: Developer console, CI/CD pipelines, advanced RBAC
- Cost: Per node subscription

**Comparison Table**:

```
Feature          | GKE    | EKS   | AKS   | OKE
─────────────────┼────────┼───────┼───────┼─────
Control Plane    | Free   | $0.1/h| Free  | Free
Easiest Setup    | ★★★★★ | ★★★★  | ★★★★★| ★★★
Cost             | Mid    | High  | Low   | Mid
Multi-cloud      | No     | No    | No    | No
Learning Curve   | Low    | Mid   | Low   | Mid
```

---

## kubeconfig & Context Management

### kubeconfig Structure

**Default Location**: `~/.kube/config`

**Format**: YAML file with three sections:

```yaml
apiVersion: v1
kind: Config
clusters:
  - name: production-cluster
    cluster:
      server: https://api.prod.example.com:6443
      certificate-authority-data: LS0tLS1CRUdJTi... # base64 CA cert
  - name: staging-cluster
    cluster:
      server: https://api.staging.example.com:6443
      certificate-authority: /path/to/ca.crt

contexts:
  - name: production-admin
    context:
      cluster: production-cluster
      user: prod-admin
      namespace: default
  - name: staging-dev
    context:
      cluster: staging-cluster
      user: staging-developer
      namespace: development

users:
  - name: prod-admin
    user:
      client-certificate-data: LS0tLS1CRUdJTi... # base64
      client-key-data: LS0tLS1CRUdJTi... # base64
  - name: staging-developer
    user:
      token: eyJhbGciOiJIUzI1NiIs... # Bearer token (JWT)

current-context: production-admin  # Which context is active
```

### Context Operations

```bash
# View current context
kubectl config current-context

# List all contexts
kubectl config get-contexts
# Output:
# CURRENT   NAME                 CLUSTER            AUTHINFO          NAMESPACE
# *         production-admin     production-cluster prod-admin        default
#           staging-dev          staging-cluster    staging-developer development

# Switch context
kubectl config use-context staging-dev

# Set default namespace for context
kubectl config set-context staging-dev --namespace=development

# View full kubeconfig
kubectl config view

# View kubeconfig with credentials (UNSAFE!)
kubectl config view --raw

# Create new context
kubectl config set-context new-context --cluster=my-cluster --user=my-user --namespace=my-ns

# Delete context
kubectl config delete-context staging-dev
```

### Multiple kubeconfig Files

```bash
# Merge multiple configs
export KUBECONFIG=~/.kube/config:~/kube-configs/work-cluster:~/kube-configs/home-lab

# Create unified file
kubectl config view --flatten > ~/.kube/merged-config

# Make permanent
export KUBECONFIG=~/.kube/merged-config
# Add to ~/.bashrc or ~/.zshrc for persistence
```

### Authentication Methods

```yaml
# Method 1: Certificates (mTLS)
users:
- name: admin
  user:
    client-certificate-data: ...
    client-key-data: ...

# Method 2: Bearer Tokens
users:
- name: user-token
  user:
    token: eyJhbGciOi...

# Method 3: Basic Auth (DEPRECATED)
users:
- name: basic-user
  user:
    username: admin
    password: secretpassword

# Method 4: OpenID Connect (OIDC)
users:
- name: oidc-user
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: /usr/bin/oidc-login
      args:
      - get-token
      - --oidc-issuer-url=https://auth.example.com

# Method 5: Cloud Provider IAM (AWS IAM)
# No credentials in kubeconfig
# Uses AWS SDK for authentication
```

**Interview Questions**:
- Q: "How do you give a developer access to only their namespace?"  
  A: "1) Create context with namespace. 2) Create RBAC Role/RoleBinding limiting to namespace. 3) Share kubeconfig. 4) Restrict API access via ServiceAccount."

- Q: "What if someone has your kubeconfig file?"  
  A: "They have full access (contains credentials). Rotate credentials immediately. Check API server audit logs for unauthorized access. Remove old credentials from cluster."

---

## Pod Lifecycle in Detail

### Complete Pod Creation Process

```
Step 1: User applies YAML
┌────────────────────────────────┐
kubectl apply -f pod.yaml
└────────────────┬───────────────┘
                 │
Step 2: API Server processes request
┌────────────────▼───────────────────────────────┐
│ 1. Authentication (cert/token/webhook)         │
│ 2. Authorization (RBAC check)                  │
│ 3. Admission Controllers (mutating/validating) │
│ 4. Validation (YAML schema)                    │
│ 5. Store in etcd                               │
└────────────────┬───────────────────────────────┘
                 │
Step 3: Scheduler watches for unscheduled pods
┌────────────────▼───────────────────────────────┐
│ 1. Filter nodes (resources, labels, taints)    │
│ 2. Score nodes (best fit)                      │
│ 3. Bind pod to node                            │
│ 4. Update etcd: pod.spec.nodeName = node-1    │
└────────────────┬───────────────────────────────┘
                 │
Step 4: Kubelet on assigned node watches API
┌────────────────▼───────────────────────────────┐
│ 1. Retrieve pod spec from API server           │
│ 2. Create pod sandbox (network ns, IP)         │
│ 3. Mount volumes                               │
│ 4. Pull container image                        │
│ 5. Create containers                           │
│ 6. Start containers                            │
│ 7. Run probes (startup, liveness, readiness)  │
└────────────────┬───────────────────────────────┘
                 │
Step 5: Pod running
┌────────────────▼───────────────────────────────┐
│ Pod Status: Running                            │
│ Container Status: Running                      │
│ Conditions: Initialized, Ready, Scheduled      │
└────────────────────────────────────────────────┘
```

### Pod Initialization

```
Pod Conditions (all must be True for Ready=True):

1. PodScheduled: Pod assigned to node (Scheduler)
2. Initialized: All Init Containers passed (Kubelet)
3. ContainersReady: All containers ready (Kubelet)
4. Ready: Can receive traffic (Kubelet)
```

### Init Containers

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  initContainers:  # Run before app containers
  - name: init-db
    image: busybox
    command: ['sh', '-c', 'echo waiting for db; sleep 5']
  - name: init-config
    image: myconfig:latest
    volumeMounts:
    - name: config-vol
      mountPath: /config
  containers:  # Run after all init containers succeed
  - name: app
    image: myapp:latest
    volumeMounts:
    - name: config-vol
      mountPath: /config
  volumes:
  - name: config-vol
    emptyDir: {}

Behavior:
- Init containers run sequentially (one at a time)
- Each must exit with code 0 (success)
- If any fails, kubelet restarts init sequence
- Main containers only start after ALL init containers succeed
- Init containers DON'T run during restarts (only once)

Use Cases:
- Wait for external dependencies (database startup)
- Generate configuration from environment
- Perform security checks
- Clone git repos / download files
```

### Pod Termination (Graceful Shutdown)

```
Termination Sequence:

Step 1: Receive SIGTERM
┌──────────────────────────────────────┐
│ Controller marks pod for deletion     │
│ (deletionTimestamp set in metadata)  │
│ Pod is removed from Service endpoints │
└────────────┬─────────────────────────┘
             │
Step 2: Grace Period (default 30 seconds)
┌────────────▼──────────────────────────────┐
│ kubelet sends SIGTERM to containers       │
│ Application should:                       │
│ 1. Stop accepting new requests            │
│ 2. Finish in-flight requests              │
│ 3. Close database connections             │
│ 4. Release resources                      │
└────────────┬──────────────────────────────┘
             │ (waiting for graceful shutdown...)
             │ ← Application has until termination grace period
             │
Step 3: Grace Period Expired
┌────────────▼──────────────────────────────┐
│ kubelet sends SIGKILL (force terminate)   │
│ Container stopped immediately             │
│ Pod removed from cluster                  │
└──────────────────────────────────────────┘

Graceful termination in code:
python:
signal.signal(signal.SIGTERM, shutdown_handler)

nodejs:
process.on('SIGTERM', () => {
  server.close(() => {
    process.exit(0);
  });
});

java:
Runtime.getRuntime().addShutdownHook(new Thread(() -> {
  // cleanup logic
}));
```

```yaml
# Configure grace period
spec:
  terminationGracePeriodSeconds: 60  # Wait up to 60s
  containers:
  - name: app
    lifecycle:
      preStop:  # Hook before termination
        exec:
          command: ["/bin/sh", "-c", "sleep 15"]  # Wait for load balancer updates
```

---

## Pod Troubleshooting Guide

### Common Pod States and Solutions

```
┌─────────────────────────────────────────────────────────────┐
│ STATUS: Pending                                             │
├─────────────────────────────────────────────────────────────┤
│ Causes:                                                     │
│                                                             │
│ 1. Insufficient Resources                                   │
│    Diagnosis: kubectl describe pod → "Insufficient..."      │
│    Fix: Increase resources or reduce pod requests           │
│                                                             │
│ 2. ImagePullBackOff / ErrImagePull                          │
│    Diagnosis: "Failed to pull image", "Repository unknown" │
│    Causes:                                                   │
│    - Wrong image name/tag                                   │
│    - Image registry credential missing                      │
│    - Network issue                                          │
│    Fix: Check image, add ImagePullSecrets                   │
│    kubectl create secret docker-registry regcred \          │
│      --docker-server=docker.io \                            │
│      --docker-username=myuser \                             │
│      --docker-password=mypass                               │
│                                                             │
│ 3. CreateContainerConfigError                               │
│    Diagnosis: "Error creating container"                    │
│    Causes:                                                   │
│    - ConfigMap/Secret doesn't exist                         │
│    - Mount path issue                                       │
│    Fix: Verify ConfigMap/Secret exists in same namespace    │
│                                                             │
│ 4. Node affinity / Label selector mismatch                  │
│    Diagnosis: "No nodes match pod selector"                 │
│    Fix: Check nodeSelector, nodeAffinity, taints           │
│         kubectl get nodes --show-labels                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STATUS: CrashLoopBackOff                                    │
├─────────────────────────────────────────────────────────────┤
│ Causes:                                                     │
│                                                             │
│ 1. Application Crash                                        │
│    Diagnosis: kubectl logs <pod>                            │
│    The logs will show the error                             │
│    Fix: Fix application code/config                         │
│                                                             │
│ 2. Command/Entry Point Wrong                                │
│    Diagnosis: Check Dockerfile CMD/ENTRYPOINT              │
│    Fix: Verify command exists in image                      │
│                                                             │
│ 3. Health Check Failing Immediately                         │
│    Diagnosis: Startup/Liveness probe failing                │
│    Fix: Remove probe or increase initialDelaySeconds        │
│                                                             │
│ 4. OOMKilled                                                │
│    Diagnosis: kubectl describe → "Reason: OOMKilled"       │
│    Memory exceeded limits                                   │
│    Fix: Increase memory limits or optimize app              │
│                                                             │
│ Debugging:
│ kubectl logs <pod> --previous  # Logs before crash          │
│ kubectl get pod -o yaml  # Check configuration              │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STATUS: ImagePullBackOff                                    │
├─────────────────────────────────────────────────────────────┤
│ Exponential Backoff: 1s, 2s, 4s, 8s, 16s, 32s, 64s, 5min   │
│ (kubelet keeps retrying with increasing delays)            │
│                                                             │
│ Fix: kubectl set image deployment/myapp \                  │
│      myapp=correctimage:tag                                 │
│      (Triggers new pod with correct image)                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ STATUS: RunContainerError                                   │
├─────────────────────────────────────────────────────────────┤
│ Container failed to start at runtime                        │
│                                                             │
│ Causes:                                                     │
│ - Volume mount failed                                       │
│ - Security context issue                                    │
│ - Resource limit exceeded                                   │
│ - Host port already in use                                  │
│                                                             │
│ Diagnosis: kubectl describe pod → Events section            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Interview Preparation & FAQs

### Scenario-Based Questions

**Q1: Cluster runs out of memory. How do you recover?**

A: Strategy depends on situation:

Option 1 (Immediate):
1. Drain least critical node: `kubectl drain node-1 --ignore-daemonsets`
   - Evicts all pods to other nodes
   - Reduces memory pressure
2. Wait for Cluster Autoscaler to add new node
3. Uncordon node after it's drained: `kubectl uncordon node-1`

Option 2 (Proper):
1. Upgrade nodes to bigger instance type
2. Use Horizontal Pod Autoscaler to scale based on memory
3. Implement resource requests/limits properly

Option 3 (Scaling):
1. Enable Cluster Autoscaler
2. Use Node Affinity to distribute pods
3. Implement Pod Disruption Budgets

---

**Q2: Application works locally but fails in K8s. Troubleshooting steps?**

A: Systematic approach:

```
1. Check Pod Status
   kubectl get pods
   kubectl describe pod <name>

2. Check Logs
   kubectl logs <pod-name>
   kubectl logs <pod-name> -p  # previous (before crash)

3. Check Resource Constraints
   kubectl top pod <pod-name>
   Are limits too low?

4. Check Dependencies
   - Can pod reach database?
   - kubectl exec -it <pod> -- sh
   - telnet database:5432
   - Check DNS: nslookup database

5. Check Security
   - NetworkPolicy blocking?
   - SecurityPolicy enforcing?
   - RBAC permissions?

6. Check Probes
   - Liveness/Readiness probes? Failing?
   - kubectl describe pod → Conditions

7. Compare Environments
   - Environment variables different?
   - Secrets/ConfigMaps correctly mounted?
   - Volumes accessible?
```

---

**Q3: Need to do a zero-downtime upgrade of critical service. How?**

A: Using Deployments with strategy:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: critical-app
spec:
  replicas: 5  # Multiple replicas for HA
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2           # 2 extra during update
      maxUnavailable: 0     # NEVER have unavailable
  template:
    metadata:
      labels:
        app: critical-app
    spec:
      affinity:
        podAntiAffinity:    # Spread across nodes
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - critical-app
            topologyKey: kubernetes.io/hostname
      containers:
      - name: app
        image: myapp:v2     # New version
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 30"]  # Wait for LB updates
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
```

Procedure:
1. Update image tag in Deployment
2. Rolling update begins automatically
3. Readiness probes ensure traffic only goes to ready pods
4. Old pods get 30s preStop grace period
5. New requests go to new pods during update
6. Rollback possible: `kubectl rollout undo deployment/critical-app`

---

**Q4: How do you implement multi-region failover?**

A: Multiple approaches:

Option 1: External Load Balancer
```
Global Load Balancer (CloudFlare, Route53)
    │
    ├─► Region 1 (Primary)
    │   └─► K8s Cluster 1
    │
    └─► Region 2 (Secondary)
        └─► K8s Cluster 2

Health checks determine which region receives traffic
If region1 unhealthy, traffic goes to region2
```

Option 2: Helm + GitOps
```
Use Flux or ArgoCD
- Git repo has manifests for all regions
- Each cluster watches its branch
- Automated failover via DNS change
```

Option 3: Service Mesh
```
Istio/Linkerd cross-cluster:
- Service mesh extends across clusters
- Automatic failover
- Traffic distribution policies
```

---

### Common Kubernetes Misconceptions

**Misconception 1**: "Kubernetes manages networking automatically"
**Reality**: K8s provides Service abstraction, but networking details depend on CNI plugin (Flannel, Calico, Cilium). You need to understand networking for troubleshooting.

**Misconception 2**: "Kubernetes is self-healing, so I don't need monitoring"
**Reality**: K8s restarts failed pods but can't fix misconfigured apps or resource exhaustion. Monitoring is essential for production.

**Misconception 3**: "Scale by increasing CPU limits"
**Reality**: Limits don't increase capacity; they restrict it. Scale by increasing replicas and adding nodes.

**Misconception 4**: "Pods with same label are always on different nodes"
**Reality**: Only if podAntiAffinity is specified. By default, K8s can schedule multiple pods of same app on one node.

**Misconception 5**: "Deleting a pod is faster than rebooting"
**Reality**: Pod deletion gracefully shuts down (30s default). Aggressive deletion (`--grace-period=0 --force`) can cause data loss.

---

### Key Metrics for Production Readiness

```
1. Pod Metrics
   - Pod restart count (high = instability)
   - Pod eviction rate (resource pressure)
   - Failed pod percentage

2. Node Metrics
   - CPU utilization (> 80% = tight)
   - Memory utilization (> 85% = risk)
   - Disk usage (> 90% = alert)
   - Network I/O

3. Cluster Metrics
   - API server latency (< 100ms ideal)
   - etcd latency (< 50ms ideal)
   - Controller manager loop duration
   - Scheduler latency

4. Application Metrics
   - Response time (p95, p99)
   - Error rate
   - Throughput
   - Dependency latency

5. Cost Metrics
   - Unused resource requests
   - Node utilization
   - Wasted capacity
```

---

### Essential kubectl Commands for Interviews

```bash
# Cluster Info
kubectl cluster-info
kubectl get nodes -o wide
kubectl top nodes
kubectl describe node node-1

# Pod Management
kubectl get pods -A  # All namespaces
kubectl get pods --sort-by=.metadata.creationTimestamp
kubectl get pods --field-selector=status.phase=Pending
kubectl get pods --field-selector=status.phase=CrashLoopBackOff
kubectl get pods -o json | jq '.items[].spec.containers[].resources'

# Debugging
kubectl logs <pod>
kubectl logs <pod> -f  # Follow
kubectl logs <pod> --previous  # Before crash
kubectl describe pod <pod>
kubectl exec -it <pod> -- /bin/bash
kubectl port-forward <pod> 8080:8080

# Troubleshooting
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
kubectl get all -n <namespace>
kubectl api-resources
kubectl explain pod.spec

# Scaling & Updates
kubectl scale deployment web --replicas=5
kubectl rollout status deployment/web
kubectl rollout history deployment/web
kubectl rollout undo deployment/web
kubectl set image deployment/web web=image:v2 --record

# Resource Management
kubectl top pods
kubectl apply -f deployment.yaml --dry-run=client -o yaml
kubectl edit deployment web
kubectl patch deployment web -p '{"spec":{"replicas":10}}'

# Cleanup
kubectl delete pod <pod-name>
kubectl delete deployment <deployment-name>
kubectl delete all -n <namespace>  # Delete all resources
```

---

### Final Interview Tips

1. **Always clarify requirements**: "Are we talking production or development? What's the scale?"

2. **Mention trade-offs**: "This approach is simpler but less scalable. A better approach would be..."

3. **Show operational thinking**: Discuss monitoring, logging, alerting alongside architecture

4. **Know your limits**: "I haven't worked with that specific tool, but here's how I'd approach learning it..."

5. **Think about costs**: "The most scalable solution might be expensive. We should balance performance with cost."

6. **Security first**: Always mention RBAC, network policies, resource quotas in production designs

7. **Demonstrate hands-on experience**: "In my last project, we faced this issue and solved it by..."

---

## Conclusion

Kubernetes is a complex system built on solid principles: declarative configuration, reconciliation loops, and separation of concerns. Success comes from:

1. **Understanding core concepts deeply** (Pods, Services, Deployments)
2. **Appreciating the architecture** (Control Plane vs Workers)
3. **Operational readiness** (Monitoring, logging, troubleshooting)
4. **Continuous learning** (K8s evolves rapidly)

Master these concepts, and you'll excel in modern DevOps roles.

---

**Version**: 1.0  
**Last Updated**: March 2026  
**For**: CKAD, CKA exam preparation and production readiness
