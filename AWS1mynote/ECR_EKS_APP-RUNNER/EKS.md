
# Comprehensive Study Notes: Amazon EKS (Elastic Kubernetes Service)

## 1. Introduction to Amazon EKS

**Amazon Elastic Kubernetes Service (EKS)** is a managed service that runs Kubernetes on AWS without needing to install, operate, or maintain your own Kubernetes control plane or nodes.

* **Upstream Compatible:** EKS runs "vanilla" Kubernetes and is certified conformant, meaning it supports all standard Kubernetes tools and plugins.


* **Versioning:** It supports at least 6 versions of Kubernetes at any given time, allowing sufficient time for testing and upgrades.


* **Reliability:** It is designed for high availability and security, automating critical tasks like patching and provisioning.

### ECS Limitations that EKS Solves

<img width="1111" height="634" alt="image" src="https://github.com/user-attachments/assets/7f746daa-531f-46a9-9d44-20edafb699eb" />

---
<img width="948" height="535" alt="image" src="https://github.com/user-attachments/assets/5da802ea-43fd-4273-87fd-4f7ee7d2103a" />

---

## 2. EKS Architecture

The EKS architecture is divided into two distinct planes: the **Control Plane** (managed by AWS) and the **Data Plane** (managed by the customer).

### **A. Control Plane (AWS Managed)**

The Control Plane runs in an **EKS-managed VPC** within an AWS account separate from the customer's. It is designed to be highly available across **3 Availability Zones (AZs)** .

**Key Components in the Control Plane:**

* **API Server Instances:** These act as the front-end for the Kubernetes control plane, exposing the API and processing RESTful requests.


* **etcd Instances:** A highly available key-value store that acts as the source of truth for all cluster data.


* **Network Load Balancer (NLB):** Routes external traffic to the API servers.


* **Controller Manager:** Runs background processes like the Node Controller (monitors health) and Replication Controller (maintains pod counts).


* **Scheduler:** Decides which node a newly created pod should run on based on resource requirements and constraints.

<img width="1403" height="912" alt="image" src="https://github.com/user-attachments/assets/e31afb6d-c856-4465-b5f5-1b2844501fe0" />




### **B. Data Plane (Customer Managed)**

The Data Plane consists of the compute resources where your applications actually run. These reside in the **Customer's AWS account** and connect to the Control Plane via the EKS endpoint.

**Key Components in the Data Plane:**

* **Worker Nodes:** EC2 instances that host the Pods (containers).


* **Node Groups:** A logical collection of nodes that can be managed together (e.g., for scaling).
  
<img width="1247" height="714" alt="image" src="https://github.com/user-attachments/assets/0aa09587-e598-4ad9-a2f1-0239c67e91f4" />



---

## 3. Deep Dive: Kubernetes Components

Understanding the specific roles of components within the Control Plane and Worker Nodes is critical for EKS interviews.

### **Control Plane Components** (The Brain)

| Component | Function |
| --- | --- |
| **API Server** | Validates and configures data for API objects (pods, services, etc.) and processes all REST requests. |
| **etcd** | Stores the entire cluster state. It requires careful backup planning as it is the single source of truth. |
| **Scheduler** | Watches for unscheduled pods and assigns them to nodes based on resource availability and policies. |
| **Controller Manager** | Manages the state of the cluster (e.g., bringing up new pods if some crash). |

### **Node Components** (The Muscle)

| Component | Function |
| --- | --- |
| **Kubelet** | An agent that runs on *every* node. It ensures that containers are running in a Pod and reports the node's status back to the API server. |
| **Kube-proxy** | Maintains network rules on the node, allowing network communication to your Pods from inside or outside the cluster. |
| **Container Runtime** | The software responsible for actually running the containers (e.g., Docker, containerd). |

---

## 4. EKS Operational Modes

EKS offers flexible ways to manage the compute layer (Data Plane) depending on your operational needs.

### **1. Standard Mode (EC2)**

* **Description:** You use EKS-managed control plane with self-managed or managed EC2 worker nodes.
* **Pros:** Full control over worker node configuration (OS, instance types).
* **Best For:** Customization, specific instance requirements (e.g., GPU), and predictable workloads.

### **2. Fargate Mode (Serverless)**

* **Description:** Serverless compute for pods. AWS manages the underlying infrastructure completely.
* **Pros:** No node management required; pay-per-pod execution model.
* **Best For:** Simplicity, variable workloads, and reducing operational overhead.

### **3. Hybrid Mode**

* **Description:** A combination of EC2 and Fargate in the same cluster.
* **Best For:** Mixed requirements where predictable workloads run on reserved EC2 instances and variable spikes are handled by Fargate.
  
<img width="948" height="554" alt="image" src="https://github.com/user-attachments/assets/4506d6e6-3d97-4125-bb90-f37f7f37eeec" />

---

## 4. **Self-Managed Worker Nodes** vs **Managed Node Groups** And Separation of **AWS Responsibility (🟠)** vs **Customer Responsibility (🔵)**


### 🟠 AWS Responsibility (Always)

### ✅ Control Plane (Fully Managed by AWS)

* API Server
* Scheduler
* Controller Manager
* etcd (cluster state store)
* High Availability (Multi-AZ)
* Control plane upgrades

You **never manage master nodes** in EKS.

---

### 🔵 Self-Managed Workers

You manage everything in the **data plane**:

* OS patching
* Kubelet & container runtime
* AMI selection
* Auto Scaling Groups
* Node upgrades
* Node lifecycle replacement

⚠ High operational overhead.

---
<img width="948" height="377" alt="image" src="https://github.com/user-attachments/assets/f249ac7f-a327-44fa-aaf2-6e7bd6784705" />

---

### 🔵 Managed Node Groups

AWS manages:

* OS updates
* AMI updates
* Kubelet upgrades
* Node lifecycle
* Rolling node updates

You manage:

* Instance type selection
* Min/Max scaling
* Kubernetes configs (RBAC, policies, HPA, etc.)

✅ Recommended for production.

---

# 🔥 Key Interview Differences

| Feature              | Self-Managed | Managed Node Groups |
| -------------------- | ------------ | ------------------- |
| OS & Patching        | You          | AWS                 |
| Node Upgrade         | You          | AWS                 |
| Operational Overhead | High         | Low                 |
| Production Ready     | Complex      | Preferred           |

---

## 6. Deployment Strategies & Tools

How do you actually create and manage an EKS cluster?

* **eksctl (Recommended):** The official CLI tool for EKS. It allows for simple, one-line cluster creation and uses YAML-based configuration. It automatically handles complex tasks like IAM roles and VPC setup.
* **Infrastructure as Code (IaC):** Using tools like **Terraform**, **AWS CloudFormation**, or **AWS CDK**. This is best for production environments as it enables version control and repeatability.
* **AWS Management Console:** A visual wizard good for learning and exploration, but less suitable for automation.

---

## 7. Kubernetes Object Hierarchy

EKS manages a hierarchy of resources to organize your application.

* **Workloads:** Define *what* runs. Examples: `Pods`, `Deployments`, `ReplicaSets`, `DaemonSets`.
* **Cluster:** Defines the environment. Examples: `Nodes`, `Namespaces`.
* **Service & Networking:** Defines communication. Examples: `Services`, `Ingresses`.
* **Config & Storage:** Defines data and state. Examples: `ConfigMaps`, `Secrets`, `PersistentVolumeClaims` (PVC).

---

## 8. When to Choose EKS?

You should choose EKS over simpler solutions (like ECS) when:

1. **Multi-Cloud Strategy:** You need compatibility across different clouds (AWS, Azure, On-Prem).
2. **Complex Architectures:** You are building complex microservices requiring advanced orchestration.
3. **Existing Expertise:** Your team already has deep Kubernetes knowledge.
4. **Rich Ecosystem:** You need specific Kubernetes extensions or tools (e.g., Helm, Istio).

---

## 🔥 EKS Interview Questions & Answers

**Q1: How does EKS ensure the high availability of the Control Plane?**

* 
**Answer:** AWS provisions the Control Plane components (API Server, etcd) across **three different Availability Zones (AZs)** within an EKS-managed VPC . If an instance fails in one AZ, the others continue to serve traffic, ensuring the API remains reachable.



**Q2: What is the specific role of the "Scheduler" in the EKS Control Plane?**

* **Answer:** The Scheduler is responsible for watching newly created pods that have no assigned node. It selects a node for them to run on based on resource availability (CPU/Memory), constraints (taints/tolerations), and affinity rules.



**Q3: Explain the difference between "Managed Node Groups" and "Fargate" in EKS.**

* **Answer:**
* **Managed Node Groups:** You still run EC2 instances, but AWS automates the provisioning and lifecycle management (updates/termination). You have visibility into the EC2 instances.


* **Fargate:** It is serverless. You do not see or manage any EC2 instances. You simply define the pod's resource requirements, and AWS finds the compute to run it.



**Q4: What is `kube-proxy` and where does it run?**

* **Answer:** `kube-proxy` is a network proxy that runs on **each worker node**. It maintains network rules on the node, enabling network communication to your Pods from inside or outside the cluster.

**Q5: Why is `etcd` considered the most critical component to backup?**

* 
**Answer:** `etcd` is the "source of truth" for the entire cluster state. It stores all cluster data, including configuration, secrets, and the state of all objects. If `etcd` data is lost and no backup exists, the cluster state cannot be recovered.
