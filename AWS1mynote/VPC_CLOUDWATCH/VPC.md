# **AWS Virtual Private Cloud (VPC) - Comprehensive Interview Notes**

## **1. VPC Fundamentals & Architecture**

### **What is a VPC?**
A logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. It provides the control of a traditional data center network with the scalability of AWS.

* **Key Features:**
    * **Complete Network Control:** Define your IP address range, subnets, route tables, and network gateways.
    * **Enhanced Security:** Filter traffic using Security Groups and Network ACLs.
    * **Connectivity:** Connect your VPC to the internet, other VPCs, or your corporate data center.
* 

### **Subnets & IP Addressing (CIDR)**
A subnet is a segment of the VPC's IP address range where resources are launched.

| Subnet Type | Route Table Target | Purpose | AZ Constraint |
| :--- | :--- | :--- | :--- |
| **Public Subnet** | Route to Internet Gateway (IGW) | Resources (e.g., Load Balancers, Web Servers) can be accessed from the internet. | Must reside in a single AZ. |
| **Private Subnet** | Route to NAT Gateway | Resources (e.g., Databases, Application Servers) are isolated from public internet access. | Must reside in a single AZ. |

* **AWS Reserved IPs (Important):** AWS reserves 5 IP addresses in every subnet CIDR block (e.g., in `10.0.1.0/24`):
    * `x.x.x.0`: Network address.
    * `x.x.x.1`: VPC Router.
    * `x.x.x.2`: DNS.
    * `x.x.x.3`: Future use.
    * `x.x.x.255`: Broadcast address (not supported, reserved).

---

## **2. Networking Components & Gateways**

### **Internet Gateway (IGW)**
An Internet Gateway acts as a bridge between a VPC and the public internet, enabling bidirectional communication. It allows resources within a VPC—such as EC2 instances in public subnets—to be accessible from the internet and to initiate outbound connections to the internet. Resources must have public IP addresses to use the IGW for internet access, and the IGW does not modify the source IP address of the traffic. It is a highly available, fully managed service that is attached to a single VPC and supports both IPv4 and IPv6 traffic. There is no additional cost for having an IGW, but you are charged for outbound internet traffic.

* **Function:** Enables communication between the VPC and the public internet.
* **Characteristics:** Horizontally scaled, redundant, highly available.
* **Role:** Provides a target for internet-bound traffic (`0.0.0.0/0`) in a public subnet's route table.
  

### **NAT Gateway**
NAT Gateway is designed to allow instances in private subnets to initiate outbound connections to the internet while preventing unsolicited inbound traffic from the internet. It translates the private IP addresses of instances in a private subnet to a public IP address (typically its own Elastic IP) before sending traffic to the internet. This translation ensures that external services cannot initiate connections to the private instances, enhancing security. A NAT Gateway only supports outbound traffic and is used for tasks like software updates or retrieving data from external sources. It is a managed service that must be created within a specific Availability Zone and is not shared across VPCs. However, it can be indirectly shared across VPCs using transit gateways or VPC peering, which can reduce costs and simplify management. Unlike the IGW, a NAT Gateway incurs charges based on its creation and usage, including data processing and number of connections. 
* **Function:** Allows instances in a **Private Subnet** to initiate outbound connections to the internet (e.g., for updates) while preventing inbound connections.
* **Deployment:** Must be launched in a **Public Subnet** and requires an Elastic IP (EIP).
* **Benefit:** Managed service, highly available within its AZ, auto-scales bandwidth (up to 5 Gbps, bursting higher).
---
A key technical point is that a NAT Gateway relies on an Internet Gateway to reach the public internet. When a private instance sends traffic through the NAT Gateway, the NAT Gateway forwards the request to the Internet Gateway, which then routes it to the internet. The response is routed back through the NAT Gateway, which translates the source IP back to the original private IP before sending it to the instance. This dependency means that a route to the Internet Gateway must be configured in the route table of the public subnet where the NAT Gateway resides.
---
### **Route Tables**
* A set of rules (routes) that determine where network traffic from your subnet is directed.
* **Constraint:** Every subnet must be associated with exactly one route table.

---

## **3. VPC Security: Security Groups vs. Network ACLs**

This is a key interview differentiation point, focusing on statefulness and level of operation.

| Feature | Security Groups (SG) | Network ACLs (NACL) |
| :--- | :--- | :--- |
| **Level of Operation** | **Instance Level** (ENI) | **Subnet Level** (Subnet boundary) |
| **State** | **Stateful:** Return traffic is automatically allowed regardless of outbound rules. | **Stateless:** Return traffic must be explicitly allowed by a corresponding rule. |
| **Rule Evaluation** | All rules are evaluated before a decision to allow traffic. | Rules are evaluated in **numerical order** (lowest number first). |
| **Default Policy** | Deny all inbound, Allow all outbound. | Allow all inbound, Allow all outbound. |
| **Rule Types** | **Allow** rules only (cannot explicitly deny). | **Allow and Deny** rules (used to block specific IP addresses). |
* 

---

## **4. VPC Connectivity Options**

### **A. VPC Peering**
* **Definition:** A VPC peering connection is a networking connection between two Virtual Private Clouds (VPCs) that enables private traffic routing between them using private IPv4 or IPv6 addresses, allowing instances in either VPC to communicate as if they were on the same network.
---
  <img width="820" height="422" alt="image" src="https://github.com/user-attachments/assets/24577b55-6548-48a9-b518-da50345964e1" />
  
---
* **Key Features:** Direct network route, no gateway, traffic stays on the AWS network.
* **Limitations (Critical for Interviews):**
    * **No Transitive Peering:** Cannot route traffic from VPC A to VPC C via VPC B.
    * **No Overlapping CIDRs:** VPCs must have unique IP ranges.
    * **Scale:** Limited to 125 connections per VPC; managing a large "full mesh" is complex. 

### **B. AWS Transit Gateway (TGW)**
* **Definition:** AWS Transit Gateway is a fully managed, highly scalable network transit hub provided by Amazon Web Services (AWS) that serves as a central point for connecting multiple Amazon Virtual Private Clouds (VPCs), on-premises networks, VPNs, Direct Connect connections, and other cloud networks.

  ---
  <img width="1058" height="576" alt="image" src="https://github.com/user-attachments/assets/d9e719ca-5e2b-4c43-8592-7f3a55ee445c" />
  
  ---
* **Architecture:** Hub-and-spoke model.
* **Advantage:** Supports **Transitive Routing**, simplifying network architecture at scale.
* **Scale:** Connects thousands of VPCs with centralized control.

### **C. Transit VPC**
* **Definition:** A Transit VPC in AWS is a reference architecture that serves as a global network transit center, enabling connectivity between multiple, geographically dispersed Virtual Private Clouds (VPCs) and remote networks, such as on-premises data centers or partner networks.
---
<img width="881" height="577" alt="image" src="https://github.com/user-attachments/assets/d3ecde4e-1c1e-490c-8454-9737488c0af6" />

---
### Key Details
* Central **hub VPC** with VPN/router appliances
* Spoke VPCs connect via **IPsec VPN**
* **BGP** enables dynamic route exchange
* Supports **VPC-to-VPC**, **VPC-to-on-prem**, and **cross-region** connectivity
* Typically deployed using **CloudFormation templates**
---
### Features
* Hub-and-spoke topology
* Dynamic routing (BGP)
* Centralized routing and security control
* Reduced number of network connections
* Automated deployment support
---
### Advantages
* Simplifies network architecture
* Avoids full-mesh VPC peering
* Centralized security and monitoring
* Scales better than VPC peering
* Flexible multi-region connectivity
---

### Limitations

* Requires **EC2-based VPN appliance management**
* Higher operational overhead
* Manual scaling and high-availability setup
* Lower performance compared to AWS-native services
* Considered **legacy** compared to Transit Gateway
---

### Quick Interview Note

> *Transit VPC is largely replaced by **AWS Transit Gateway**, which provides the same functionality as a fully managed service.*


### **D. AWS PrivateLink (Interface Endpoints)**
* **Function:** Enables private access to AWS services (e.g., S3, DynamoDB) or services hosted by other AWS accounts without using public IPs and without traversing the public internet.
* **Mechanism:** Creates an Elastic Network Interface (ENI) in your subnet that serves as an entry point to the service.
 ---
<img width="1190" height="579" alt="image" src="https://github.com/user-attachments/assets/6c43721e-897f-4940-8bfe-b8c9c325747b" />

---
---

## **5. Hybrid Connectivity (On-Premises to Cloud)**

### **A. AWS Site-to-Site VPN**
* **Description:** An encrypted connection (IPsec protocol) between your on-premises network and your VPC over the public internet.
* **Components:** **Virtual Private Gateway (VGW)** or **Transit Gateway** (AWS side) + **Customer Gateway** (on-premise side).
* **Availability:** Utilizes two tunnels for high availability (active/standby).

### **B. AWS Direct Connect (DX)**
* **Description:** Establishes a **dedicated, private physical network connection** from your premises to AWS.
* **Benefits:** Consistent network performance, stable low latency, and bypassing the public internet.
* **Use Case:** High-throughput, mission-critical workloads.

### **C. AWS Client VPN**
* **Description:** A managed client-based VPN service for secure access for remote users to AWS resources using an OpenVPN client.
* **Authentication:** Supports Active Directory, Certificate-based, and SAML.

---
---

### VPG (Virtual Private Gateway) – AWS

In **AWS**, **VPG** stands for **Virtual Private Gateway**.

#### What it is

A **Virtual Private Gateway** is the **AWS-side VPN endpoint** that enables a secure connection between:

* Your **VPC**, and
* Your **on-premises data center** or another network

It is commonly used with:

* **Site-to-Site VPN**
* **AWS Direct Connect**

#### Where it sits

```
On-Prem Network ── VPN / Direct Connect ── VPG ── VPC
```

#### Key points

* Attached to **one VPC**
* Acts as the **entry/exit point** for VPN traffic
* Uses **IPsec tunnels**
* Requires **route table updates** in the VPC
* Alternative to **Transit Gateway** (TGW)

#### VPG vs Transit Gateway

| Feature     | VPG        | TGW                           |
| ----------- | ---------- | ----------------------------- |
| Scope       | Single VPC | Multiple VPCs                 |
| Scalability | Limited    | Highly scalable               |
| Use case    | Simple VPN | Hub-and-spoke, large networks |
| Cost        | Lower      | Higher                        |

---
---
## **6. Load Balancing Types**

| Load Balancer | Layer | Use Case & Key Features |
| :--- | :--- | :--- |
| **Application Load Balancer (ALB)** | Layer 7 (HTTP/HTTPS) | Content-based routing (paths, hosts, headers), supports microservices, HTTP/2, gRPC. |
| **Network Load Balancer (NLB)** | Layer 4 (TCP/UDP) | Extremely high performance, ultra-low latency, handling millions of requests/sec. Provides a **static IP address** per AZ. |
| **Gateway Load Balancer (GWLB)** | Layer 3 (IP) | Deploying and managing third-party network virtual appliances (firewalls, IDS/IPS). Uses **GENEVE** protocol. |
Below is a **clear, structured, and exam-ready explanation** of **VPC Endpoint types** and **when each is suitable**, with practical decision rules.

---

# VPC Endpoint Types

AWS provides **two types of VPC Endpoints**:

1. **Gateway Endpoint**
2. **Interface Endpoint (AWS PrivateLink)**

---

## 1. Gateway Endpoint

### What it is

* A **route-table based** endpoint
* Adds a route to AWS-managed **prefix lists**
* **No ENIs**, no security groups

### Supported services

* **Amazon S3**
* **Amazon DynamoDB**

(Only these two — nothing else)

---

### When Gateway Endpoint is Suitable

✔ Private access to **S3 or DynamoDB**
✔ Want to avoid **NAT Gateway / Internet Gateway**
✔ Need **zero cost** endpoint
✔ Simple architecture

Example:

```
EC2 (private subnet) → S3 (via AWS backbone)
```

---

### When NOT Suitable

✖ Access to any service other than S3/DynamoDB
✖ Need security-group level control
✖ Need on-premises access via VPN/DX

---

### Key Exam Points

* Works at **route table level**
* Automatically adds route:

  ```
  pl-xxxx → vpce-xxxx
  ```
* **Free**
* No Private DNS

---

## 2. Interface Endpoint (PrivateLink)

### What it is

* Creates **Elastic Network Interfaces (ENIs)** in your subnet
* Uses **Private DNS**
* Protected by **Security Groups**

### Supported services

* Most AWS services:

  * EC2 API
  * SSM
  * ECR
  * CloudWatch
  * Secrets Manager
* **Custom services** (via Endpoint Service)

---

### When Interface Endpoint is Suitable

✔ Private access to **AWS APIs**
✔ Access services from **private subnet** without Internet
✔ Fine-grained security via **security groups**
✔ Cross-account or SaaS access

Example:

```
EC2 → ENI (Private IP) → AWS service
```

---

### When NOT Suitable

✖ Accessing S3 or DynamoDB (Gateway is better)
✖ Cost-sensitive, high-volume traffic
✖ Want simple routing (interface is more complex)

---

### Key Exam Points

* Uses **ENIs**
* Requires **subnet selection**
* Supports **Private DNS**
* **Hourly + data processing cost**

---

## Gateway vs Interface (Comparison Table)

| Feature         | Gateway Endpoint | Interface Endpoint |
| --------------- | ---------------- | ------------------ |
| Services        | S3, DynamoDB     | Most AWS services  |
| Network method  | Route table      | ENIs               |
| Security groups | ❌ No             | ✅ Yes              |
| Cost            | Free             | Paid               |
| Private DNS     | ❌ No             | ✅ Yes              |
| On-prem access  | ❌ No             | ✅ Yes              |
| Cross-account   | ❌ No             | ✅ Yes              |

---

## Decision Rule (Very Important)

> **If the service is S3 or DynamoDB → Gateway Endpoint**
> **Otherwise → Interface Endpoint**

---

## Real-World Scenarios

### Scenario 1

Private EC2 needs S3 access
✔ **Gateway Endpoint**

### Scenario 2

Private EC2 needs Systems Manager
✔ **Interface Endpoint**

### Scenario 3

Share internal API with another AWS account
✔ **Endpoint Service + Interface Endpoint**

### Scenario 4

Eliminate NAT Gateway for AWS APIs
✔ **Interface Endpoint**

---

## Common Exam Traps

❌ Choosing Interface Endpoint for S3
❌ Thinking Gateway Endpoint supports security groups
❌ Assuming endpoints work automatically across all subnets

---
## VPC Flow Logs — Exam & Interview–Ready Explanation (2–3 YOE)

### What VPC Flow Logs Are

**VPC Flow Logs** capture **IP traffic metadata** flowing **to and from** network interfaces in your VPC. They are used for **network visibility, troubleshooting, and security analysis**.

They **do NOT** capture packet payloads—only metadata.

---

## Where You Can Enable Flow Logs

You can create Flow Logs at three levels:

1. **VPC level** – all traffic in the VPC
2. **Subnet level** – traffic for all ENIs in a subnet
3. **ENI level** – traffic for a specific network interface

**Exam tip:** ENI-level is the most granular.

---

## What Traffic Is Logged

You can choose one of the following:

* **ACCEPT** – only allowed traffic
* **REJECT** – only denied traffic
* **ALL** – both allowed and denied (most common)

---

## Where Flow Logs Are Stored

Flow Logs can be delivered to:

* **CloudWatch Logs** (most used for troubleshooting)
* **Amazon S3** (long-term storage, analytics)
* **Kinesis Data Firehose** (advanced pipelines)

---

## Flow Log Record Format (Important)

A typical log entry includes:

* Source IP
* Destination IP
* Source port
* Destination port
* Protocol
* Packets / bytes
* **Action (ACCEPT / REJECT)**
* Start & end time

**Exam keyword:** `action = REJECT` is critical for debugging.

---

## What Flow Logs DO NOT Capture (Very Important)

They do **NOT** capture:

* Traffic to/from:

  * Amazon DNS (169.254.169.253)
  * Instance metadata (169.254.169.254)
* DHCP traffic
* ARP traffic
* Traffic between instances using **localhost**
* Packet payload or application data

---

## Common Use Cases (Interview Answers)

### 1. Debugging Connectivity Issues

* Why EC2 cannot be reached?
* Is traffic being **REJECTED by SG or NACL**?

### 2. Security & Auditing

* Identify unauthorized access attempts
* Detect port scanning

### 3. Compliance & Forensics

* Maintain network access logs

---

## Flow Logs vs Security Group vs NACL (Comparison)

| Feature        | Flow Logs  | Security Group | NACL       |
| -------------- | ---------- | -------------- | ---------- |
| Purpose        | Monitoring | Allow/Deny     | Allow/Deny |
| Stateful       | N/A        | Yes            | No         |
| Blocks traffic | No         | Yes            | Yes        |
| Logs traffic   | Yes        | No             | No         |

---

## How to Enable VPC Flow Logs (Console)

### Step-by-step

1. Go to **VPC → Your VPCs**
2. Select your VPC
3. Click **Actions → Create flow log**
4. Configure:

   * **Filter:** ALL
   * **Destination:** CloudWatch Logs
   * **Log group:** Create new
   * **IAM Role:** Create or select role
5. Click **Create flow log**

---

## IAM Permission Required

The role must allow:

* `logs:CreateLogStream`
* `logs:PutLogEvents`

---

## Sample Interview Question & Answer

**Q:** EC2 is unreachable even though SG allows traffic. How do you debug?
**A:** Enable VPC Flow Logs and check for REJECT entries to determine whether traffic is being blocked by a NACL or route issue.

---

## When NOT to Use Flow Logs

* Application-level debugging
* Payload inspection
* Real-time packet capture

---

## One-Line Exam Summary

> **VPC Flow Logs capture network traffic metadata for monitoring and troubleshooting but do not inspect packet content or block traffic.**

---



