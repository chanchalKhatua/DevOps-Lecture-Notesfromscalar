
---

# **AWS Scaling and Load Balancing
## **1. Infrastructure Capacity Management**

Infrastructure capacity management focuses on aligning compute resources with workload demand. This is implemented through two scaling approaches: **Vertical Scaling** and **Horizontal Scaling**.

---

## **1.1 Vertical Scaling (Scale Up)**

Vertical scaling enhances the capabilities of an existing node.

### **Definition**

Increasing system capacity by upgrading the hardware resources of a single machine without increasing the machine count.

### **How It Works**

* Upgrade the instance type (CPU, RAM, network performance).
* Replace the underlying machine with a more powerful one.
* Migrate workload to a higher-tier instance family.

### **Characteristics**

* Machine count remains constant (e.g., 1 machine → 1 machine).
* Beneficial for monolithic applications that cannot horizontally distribute load.

### **Example**

A cloud database on an 8 vCPU, 32 GB RAM instance is struggling.

**Upgrade path:**

* 8 vCPU → 16 vCPU
* 16 vCPU → 32 vCPU
* Eventually: 64 vCPU / 128 GB RAM / 5 TB SSD

### **Limitation**

* A physical hardware limit exists.
* Scaling pauses require downtime or failover.
* Costs grow exponentially as instance size increases.

---

## **1.2 Horizontal Scaling (Scale Out)**

Horizontal scaling increases capacity by adding more nodes.

### **Definition**

Increasing the number of servers to distribute application traffic.

### **How It Works**

* Deploy multiple identical servers (replicas).
* Traffic is balanced across servers.
* Nodes can be automatically added or removed.

### **Why Cloud Prefers It**

* No theoretical limit.
* Superior fault tolerance.
* Best fit for stateless web apps and microservices.

### **Example**

Instead of upgrading an 8 vCPU instance, add three more identical 8 vCPU instances.

---

# **2. AWS Auto Scaling**

AWS Auto Scaling automates horizontal scaling to maintain performance while optimizing costs.

---

## **2.1 Key Objectives of Auto Scaling**

* **Cost Optimization:** Removes unused capacity during low-load periods.
* **Consistent Performance:** Adds resources during spikes.
* **High Availability:** Ensures healthy instances are always running.
* **Minimal Manual Intervention:** Automatically detects, replaces, and maintains instance lifecycle.

---

## **2.2 The 3 Pillars of Auto Scaling (ASG)**

To configure ASG, define:

1. **What** to launch
2. **Where** to launch
3. **When** to scale

---

## **2.2.1 WHAT: Launch Template**

A Launch Template defines the blueprint for new EC2 instances.

### **Key Components**

* **AMI:** Defines the operating system and software baseline.
* **Instance Type:** Hardware capacity (e.g., t2.micro, m5.large).
* **Security Groups:** Network access rules.
* **Key Pair:** SSH access control.
* **IAM Role:** Permissions for instance operations.
* **User Data Script:** Install application packages at boot.

### **Why Launch Templates Are Preferred**

* Support versioning.
* Support partial parameter overrides.
* Can be reused across multiple ASGs.

### **CLI Example**

```bash
aws ec2 create-launch-template \
  --launch-template-name "web-template" \
  --version-description "version1" \
  --launch-template-data '{"ImageId":"ami-012345", "InstanceType":"t2.micro"}'
```

---

## **2.2.2 WHERE: Auto Scaling Group (ASG)**

The ASG defines the boundaries and behavior of scaling.

### **Key Attributes**

* **VPC & Subnets:** Defines where instances run.
* **AZ Spread:** For high availability across multiple zones.
* **Minimum Capacity:** Never drop below this count.
* **Maximum Capacity:** Upper boundary (cost control).
* **Desired Capacity:** Target instance count at any moment.

### **Load Balancer Integration**

ASG connects EC2 instances to:

* **Application Load Balancer (ALB)**
* **Network Load Balancer (NLB)**
  or
* **Gateway Load Balancer (GWLB)**

This ensures instances receive traffic only when healthy.

---

## **2.2.3 WHEN: Scaling Policies**

Defines when Auto Scaling Group should add or remove instances.

### **Types of Policies**

1. **Dynamic Scaling**

   * CloudWatch-based.
   * Examples:

     * Scale Out when CPU > 70%
     * Scale In when CPU < 20%

2. **Scheduled Scaling**

   * Time-based.
   * Example:

     * Increase capacity every day at 9 AM before peak traffic.

3. **Predictive Scaling**

   * Machine learning-based.
   * Anticipates future traffic based on historical patterns.

---

# **3. AWS Load Balancers (ELB Family)**

Elastic Load Balancing enables intelligent traffic distribution across multiple compute resources.

AWS provides three types:

1. **Application Load Balancer (ALB)** — Layer 7
2. **Network Load Balancer (NLB)** — Layer 4
3. **Gateway Load Balancer (GWLB)** — Layer 3

---

# **3.1 Application Load Balancer (ALB)**

### **Layer**

Operates at **Layer 7 (Application Layer)**.

### **Best Use Cases**

* Web applications
* Microservices
* API routing
* HTTP/HTTPS traffic

### **Advanced Routing**

* **Path-based routing:**
  `/api/*` → API servers
  `/auth/*` → Auth service

* **Host-based routing:**
  `blog.example.com` → Blog ASG
  `admin.example.com` → Admin ASG

* **Header-based routing**

* **Query parameter routing**

### **Target Types**

* EC2 Instances
* Containers (ECS/EKS)
* IP addresses
* Lambda functions

### **Key Features**

* WebSocket support
* HTTP/2 support
* Cookie stickiness
* WAF integration
* Authentication (OIDC/Cognito)
* Redirects & fixed responses
* Native request tracing

---

# **3.2 Network Load Balancer (NLB)**

### **Layer**

Operates at **Layer 4 (Transport Layer)**.

### **Best Use Cases**

* High-throughput, real-time workloads
* TCP/UDP traffic
* Gaming servers
* IoT workloads
* Financial transactions

### **Key Characteristics**

* Handles millions of requests per second.
* Extremely low latency.
* Zonal isolation for high resilience.

### **Networking Features**

* Static IP support
* Elastic IP support
* Source IP preservation
* Long-lived TCP connection support

---

# **3.3 Gateway Load Balancer (GWLB)**

### **Layer**

Operates at **Layer 3 (Network Layer)**.

### **Purpose**

Ideal for routing traffic through virtual appliances.

### **Use Cases**

* Firewalls
* IDS / IPS systems
* Deep Packet Inspection (DPI)
* Network analytics

### **Mechanism**

* Provides a single entry point for traffic inspection.
* Uses **GENEVE protocol** for encapsulation.
* Works as a transparent bump-in-the-wire.

---

# **4. Architectural Design Patterns**

Real-world reference architectures for common workloads.

---

## **4.1 E-Commerce Architecture**

### **Traffic Flow**

1. Internet users → **External ALB**
2. ALB → Web Tier ASG
3. Web Tier → **Internal ALB** (API Gateway-like)
4. Internal ALB → Backend app services (Search, Cart, Inventory, Auth)

### **Design Highlights**

* **WAF** in front of ALB.
* **API segmentation:** Dedicated ASG per service.
* **Path-based routing** for microservices.
* **ASG Scaling:** Target tracking (CPU = 50%, or RPS target).

---

## **4.2 Media Streaming Service**

### **Requirements**

* Ultra-low latency
* Very high throughput
* Stable long-lived connections

### **Solution**

* **Network Load Balancer** handles viewer traffic.
* **Predictive scaling** prepares servers ahead of events.
* **Multi-AZ** deployments for resilience.

---

## **4.3 SaaS (Multi-Tenant) Model**

### **Routing Logic**

* `tenantA.app.com` → Tenant A ASG
* `tenantB.app.com` → Tenant B ASG

### **Design Characteristics**

* Host-based routing using ALB.
* Tenant isolation for performance and security.
* Mixed instance types for cost optimization.
* Latency-based scaling policies.

---

# **5. Best Practices Checklist**

A reference list for designing scalable, resilient systems.

---

## **5.1 Availability**

* Always deploy across **multiple AZs**.
* Ensure ASG can launch in at least two subnets.

---

## **5.2 Health Checks**

* Use **application-level** health checks.
* Example:

  * `/health`
  * `/status`
  * `/readiness`

Avoid relying only on system-level checks.

---

## **5.3 Connection Draining (Deregistration Delay)**

* Allows in-flight requests to complete before terminating an instance.
* Prevents errors during scale-in events.

---

## **5.4 Security Configuration**

### **Load Balancer SG**

* Allow inbound 80/443 from `0.0.0.0/0`.

### **Instance SG**

* Allow inbound only from the **Load Balancer’s SG**.
* Do not expose EC2 instances directly to the internet.

---

## **5.5 Access Logging**

* Enable access logs for ALB/NLB.
* Store logs in S3 for:

  * Auditing
  * Debugging
  * Traffic analysis

