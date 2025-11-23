
---

# 📘 Advanced EC2, Storage, and Load Balancing Notes

## 1. AWS Storage Services Ecosystem
[cite_start]AWS offers a diverse range of storage services tailored to different access patterns, performance requirements, and costs[cite: 8, 10, 41].

### Storage Hierarchy
* [cite_start]**Block Storage:** **Amazon EBS (Elastic Block Store)** provides block-level storage volumes for use with EC2 instances[cite: 19, 20].
* [cite_start]**Object Storage:** **Amazon S3** offers scalable object storage for any amount of data[cite: 32, 33]. [cite_start]Includes classes like Standard, Intelligent Tiering, and One Zone-IA[cite: 7, 34].
* **File Storage:**
    * [cite_start]**Amazon EFS (Elastic File System):** A fully managed file system for EC2 (Linux-based)[cite: 39].
    * [cite_start]**Amazon FSx:** Fully managed file systems optimized for Windows File Server, Lustre, and ONTAP[cite: 15, 39, 47].
* [cite_start]**Archival:** **Amazon S3 Glacier** provides low-cost archive storage (Archive and Deep Archive tiers)[cite: 16, 39, 48].
* **Hybrid & Edge:**
    * [cite_start]**AWS Storage Gateway:** Integrates on-premises environments with cloud storage (File, Volume, and Tape Gateways)[cite: 18, 40].
    * [cite_start]**AWS Snow Family:** Physical devices (Snowball Edge, Snowmobile) for migrating large data sets[cite: 17, 38, 45].

---

## 2. Deep Dive: Amazon EBS and IOPS


### Understanding IOPS
[cite_start]IOPS (Input/Output Operations Per Second) is a critical metric for storage performance, measuring the number of read/write operations a device can perform per second[cite: 54, 57].
* [cite_start]**Importance:** It directly impacts application performance, particularly for databases and I/O-intensive workloads[cite: 58].
* [cite_start]**Measurement:** Tools like CloudWatch, `fio`, and `dd` are used to measure actual IOPS[cite: 71].

### EBS Volume Types Comparison
[cite_start]The choice of volume depends on the balance between IOPS, Throughput, and Cost[cite: 55, 62, 68].

| Volume Type | Category | Max IOPS | Max Throughput | Latency | Durability | Pricing Tier | Use Case |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **io2 Block Express** | Provisioned IOPS SSD | **256,000** | **4,000 MiB/s** | **<1ms** | **99.999%** | Highest | [cite_start]Mission-critical, sub-millisecond latency apps [cite: 55] |
| **io2** | Provisioned IOPS SSD | 64,000 | 1,000 MiB/s | ~1-2ms | **99.999%** | High | [cite_start]Business-critical apps requiring high durability [cite: 55] |
| **io1** | Provisioned IOPS SSD | 64,000 | 1,000 MiB/s | ~1-2ms | 99.8-99.9% | High | [cite_start]I/O intensive databases [cite: 55] |
| **gp3** | General Purpose SSD | 16,000 | 1,000 MiB/s | ~1-2ms | 99.8-99.9% | Medium-Low | [cite_start]General workloads, virtual desktops [cite: 55] |
| **gp2** | General Purpose SSD | 16,000 | 250 MiB/s | ~1-2ms | 99.8-99.9% | Medium | [cite_start]Boot volumes, dev/test environments [cite: 55] |
| **st1** | Throughput Optimized HDD | 500-1,000 | 500 MiB/s | ~5-10ms | 99.8-99.9% | Low | [cite_start]Big data, data warehouses, log processing [cite: 55, 67] |
| **sc1** | Cold HDD | 250 | 250 MiB/s | ~10-20ms | 99.8-99.9% | Lowest | [cite_start]Infrequently accessed data [cite: 55, 69] |

---

## 3. EC2 Snapshots and Data Protection


[cite_start]Snapshots are point-in-time copies of EBS volumes used for data protection, migration across regions/accounts, and creating new volumes[cite: 76, 85, 86].

### Snapshot Mechanics (Full vs. Incremental)
1.  [cite_start]**First Snapshot (Full):** The very first snapshot created is always a full snapshot[cite: 268].
    * [cite_start]It copies **all** data blocks written to the volume at that moment[cite: 269].
    * [cite_start]**Cost Logic:** If you have a 200 GiB volume with only 50 GiB of data, the snapshot size is 50 GiB, and you are billed for 50 GiB[cite: 272, 273].
2.  [cite_start]**Subsequent Snapshots (Incremental):** These are incremental[cite: 270].
    * [cite_start]They only save blocks that have **changed or been added** since the last snapshot[cite: 81, 270].
    * **Cost Logic:** If you change 20 GiB of data and add 10 GiB, the incremental snapshot size is 30 GiB. [cite_start]You are billed only for that additional 30 GiB[cite: 275, 276].
3.  [cite_start]**Deletion:** Deleting a snapshot only removes data unique to that snapshot; data referenced by other snapshots is preserved[cite: 125].

### Best Practices
* [cite_start]Use **AWS Backup** or automated scripts for regular creation[cite: 113].
* [cite_start]Stop the instance or detach the volume before snapshotting to ensure data consistency[cite: 116].
* [cite_start]Use lifecycle policies to automate retention and deletion[cite: 120].

---

## 4. AMI Management, Encryption, and Sharing


### AMI Copy & Encryption
You cannot simply "switch on" encryption for an existing unencrypted AMI or Snapshot. You must create a copy.
* [cite_start]**The Process:** To encrypt an unencrypted resource, you select the source AMI, initiate a copy to the same or different region, and select encryption options using a specific KMS key[cite: 133, 304].
* [cite_start]**Key Rotation:** This process is also used to re-encrypt an already encrypted AMI with a *different* KMS key[cite: 134].

### Cross-Account AMI Sharing
[cite_start]Sharing **encrypted** AMIs requires a precise multi-step configuration because security is tighter than with unencrypted AMIs[cite: 164].

1.  [cite_start]**KMS Prerequisites:** You must own the Customer Managed Key (CMK) used to encrypt the AMI[cite: 175]. [cite_start]**Note:** You *cannot* share AMIs encrypted with the default AWS-managed key[cite: 179].
2.  [cite_start]**Key Policy:** Modify the KMS Key Policy in the source account to allow the *target* account to use the key[cite: 188].
3.  [cite_start]**AMI Permissions:** Modify the AMI permissions to share it with the target account[cite: 188].
4.  [cite_start]**Target Account Action:** The target account can launch instances or create volumes but cannot re-share the AMI further[cite: 193, 194].

---

## 5. EC2 Image Builder


[cite_start]EC2 Image Builder is a fully managed service that automates the creation, management, and deployment of customized server images (Golden Images)[cite: 320, 323].

### The Problem with Manual "Golden Images"
* [cite_start]**High Overhead:** Manually patching and updating images is labor-intensive[cite: 317].
* [cite_start]**Inconsistency:** Manual builds often lack standardized security checks, leading to vulnerabilities[cite: 318].
* [cite_start]**Scaling Issues:** distributing AMIs across multiple regions and accounts requires complex custom scripting (e.g., Packer)[cite: 319].

### The Image Builder Solution
[cite_start]It uses a **Pipeline** approach to automate the workflow[cite: 335]:
1.  [cite_start]**Image Recipe:** Defines the source image (e.g., base Linux) and build components (software to install)[cite: 338].
2.  [cite_start]**Infrastructure Config:** Defines the environment for the build instance (Instance type, Subnet, Security Groups)[cite: 341].
3.  [cite_start]**Distribution Config:** Specifies target Regions and AWS Accounts for the final image[cite: 343].
4.  [cite_start]**Schedule:** Can be triggered manually or on an automated schedule (e.g., weekly patching)[cite: 344].
5.  [cite_start]**Cascading Pipelines:** You can create a "Gold Image" pipeline that feeds into workload-specific pipelines (e.g., a secured base image feeds into a "Web Server" pipeline and a "Database" pipeline) [cite: 337, 349-357].

---

## 6. AWS Load Balancing (ELB)


[cite_start]Load balancers distribute traffic across multiple targets to ensure Scalability, Security, and Availability [cite: 359-365].

### 1. Application Load Balancer (ALB)
* [cite_start]**Layer:** Operates at **Layer 7** (HTTP/HTTPS)[cite: 200].
* **Architecture:**
    * [cite_start]**Listener:** Listens for incoming traffic (e.g., port 80/443)[cite: 380].
    * [cite_start]**Rules:** Routes traffic based on HTTP headers, paths, or hostnames[cite: 382].
    * [cite_start]**Target Groups:** Logical grouping of targets (EC2, ECS, Lambda)[cite: 384].
* **Key Features:**
    * [cite_start]**Stickiness:** Supports application cookie stickiness to bind a user's session to a specific target[cite: 385].
    * [cite_start]**Microservices:** Ideal for containerized apps and microservices[cite: 202, 225].
    * [cite_start]**Serverless:** Can route traffic directly to AWS Lambda functions[cite: 391].

### 2. Network Load Balancer (NLB)
* [cite_start]**Layer:** Operates at **Layer 4** (TCP/UDP/TLS)[cite: 203].
* [cite_start]**Performance:** Designed for ultra-high performance, capable of handling millions of requests per second with ultra-low latency[cite: 203, 227].
* **Key Features:**
    * [cite_start]**Static IP:** Supports static IP addresses[cite: 227].
    * **ALB Integration:** An NLB can actually send traffic to an ALB. [cite_start]This allows you to use the Static IP of an NLB combined with the Layer 7 routing logic of an ALB[cite: 386].

### 3. Gateway Load Balancer (GWLB)
* [cite_start]**Layer:** Operates at **Layer 3** (Network/IP)[cite: 204].
* [cite_start]**Use Case:** Deploys and manages fleets of third-party virtual appliances (firewalls, deep packet inspection, IDS/IPS)[cite: 206, 230].
* [cite_start]**Protocol:** Uses the **GENEVE** protocol to encapsulate traffic[cite: 230].

### Summary Comparison

| Feature | ALB | NLB | GWLB |
| :--- | :--- | :--- | :--- |
| **Layer** | Layer 7 (Application) | Layer 4 (Transport) | Layer 3 (Network) |
| **Traffic** | HTTP, HTTPS, gRPC | TCP, UDP, TLS | IP |
| **Use Case** | Microservices, Web Apps | Extreme Performance, Static IP | Virtual Firewalls/Appliances |
| **Routing** | Path/Host-based | Port/Protocol-based | Route table injection |
