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
* **Function:** Enables communication between the VPC and the public internet.
* **Characteristics:** Horizontally scaled, redundant, highly available.
* **Role:** Provides a target for internet-bound traffic (`0.0.0.0/0`) in a public subnet's route table.

### **NAT Gateway**
* **Function:** Allows instances in a **Private Subnet** to initiate outbound connections to the internet (e.g., for updates) while preventing inbound connections.
* **Deployment:** Must be launched in a **Public Subnet** and requires an Elastic IP (EIP).
* **Benefit:** Managed service, highly available within its AZ, auto-scales bandwidth (up to 5 Gbps, bursting higher).

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
* **Definition:** A networking connection between two VPCs that routes traffic using private IP addresses.
* **Key Features:** Direct network route, no gateway, traffic stays on the AWS network.
* **Limitations (Critical for Interviews):**
    * **No Transitive Peering:** Cannot route traffic from VPC A to VPC C via VPC B.
    * **No Overlapping CIDRs:** VPCs must have unique IP ranges.
    * **Scale:** Limited to 125 connections per VPC; managing a large "full mesh" is complex.
* 

### **B. AWS Transit Gateway (TGW)**
* **Definition:** A centralized hub (cloud router) for connecting multiple VPCs, VPNs, and Direct Connect connections.
* **Architecture:** Hub-and-spoke model.
* **Advantage:** Supports **Transitive Routing**, simplifying network architecture at scale.
* **Scale:** Connects thousands of VPCs with centralized control.
* 

### **C. AWS PrivateLink (Interface Endpoints)**
* **Function:** Enables private access to AWS services (e.g., S3, DynamoDB) or services hosted by other AWS accounts without using public IPs and without traversing the public internet.
* **Mechanism:** Creates an Elastic Network Interface (ENI) in your subnet that serves as an entry point to the service.

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

## **6. Load Balancing Types**

| Load Balancer | Layer | Use Case & Key Features |
| :--- | :--- | :--- |
| **Application Load Balancer (ALB)** | Layer 7 (HTTP/HTTPS) | Content-based routing (paths, hosts, headers), supports microservices, HTTP/2, gRPC. |
| **Network Load Balancer (NLB)** | Layer 4 (TCP/UDP) | Extremely high performance, ultra-low latency, handling millions of requests/sec. Provides a **static IP address** per AZ. |
| **Gateway Load Balancer (GWLB)** | Layer 3 (IP) | Deploying and managing third-party network virtual appliances (firewalls, IDS/IPS). Uses **GENEVE** protocol. |
