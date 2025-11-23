
---

# Advanced Concepts on EC2, Storage, and Load Balancing

## 1. AWS Storage Services Overview
AWS offers a wide variety of storage services tailored to different needs, access patterns, performance requirements, and cost constraints.

### Storage Types and Hierarchy
* **Block Storage:**
    * **Amazon EBS (Elastic Block Store):** Provides block-level storage volumes for use with EC2 instances. It includes various volume types optimized for different workloads (General Purpose, Provisioned IOPS, HDD).
* **Object Storage:**
    * **Amazon S3 (Simple Storage Service):** Object storage built for any amount of data. Variants include **Standard**, **Intelligent-Tiering**, **Standard-IA** (Infrequent Access), and **One Zone-IA**.
* **File Storage:**
    * **Amazon EFS (Elastic File System):** Fully managed, serverless file system for EC2 (Linux).
    * **Amazon FSx:** Fully managed file systems optimized for specific workloads. Includes **FSx for Windows File Server**, **FSx for Lustre**, and **FSx for ONTAP**.
* **Archival Storage:**
    * **Amazon S3 Glacier:** Low-cost storage for data archiving. Includes **Glacier Archive** and **Deep Archive** tiers.
* **Hybrid and Edge Storage:**
    * **AWS Storage Gateway:** Integrates on-premises environments with cloud storage. Types include **File Gateway**, **Volume Gateway** (Stored and Cached volumes), and **Tape Gateway**.
    * **AWS Snow Family:** Physical devices for data migration and edge computing, including **Snowball Edge** and **Snowmobile**.
<img width="779" height="393" alt="image" src="https://github.com/user-attachments/assets/f51aaea8-05c6-4c94-8d69-0405316a24ac" />

---

## 2. Amazon EBS and IOPS
Input/Output Operations Per Second (IOPS) is a critical performance metric for storage systems. It measures the number of read/write operations a device can perform per second, which directly impacts application performance, especially for databases.

### EBS Volume Types Comparison
Each volume type is designed for specific performance characteristics regarding IOPS, throughput, and latency.

| Volume Type | Category | Max IOPS | Max Throughput | Latency | Durability | Pricing Tier | Use Case |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **io2 Block Express** | Provisioned IOPS SSD | 256,000 | 4,000 MiB/s | <1 ms | 99.999% | Highest | Sub-millisecond latency apps |
| **io2** | Provisioned IOPS SSD | 64,000 | 1,000 MiB/s | ~1-2 ms | 99.999% | High | Business-critical apps |
| **io1** | Provisioned IOPS SSD | 64,000 | 1,000 MiB/s | ~1-2 ms | 99.8-99.9% | High | I/O intensive databases |
| **gp3** | General Purpose SSD | 16,000 | 1,000 MiB/s | ~1-2 ms | 99.8-99.9% | Medium-Low | General workloads |
| **gp2** | General Purpose SSD | 16,000 | 250 MiB/s | ~1-2 ms | 99.8-99.9% | Medium | Boot volumes, dev/test |
| **st1** | Throughput Optimized HDD | 500-1,000 | 500 MiB/s | ~5-10 ms | 99.8-99.9% | Low | Big data, log processing |
| **sc1** | Cold HDD | 250 | 250 MiB/s | ~10-20 ms | 99.8-99.9% | Lowest | Infrequently accessed data |

---

## 3. EC2 Snapshots and Data Protection
EC2 snapshots are point-in-time copies of EBS volumes used for data protection, disaster recovery, and migration.

### Snapshot Mechanics (Full vs. Incremental)
* **First Snapshot (Full Backup):** The first snapshot created from a volume is always a full snapshot. It includes all data blocks written to the volume at the time of creation.
    * *Cost Calculation:* The size of the full snapshot is determined by the data being backed up, not the provisioned size of the volume. For example, if you snapshot a **200 GiB volume** that only contains **50 GiB of data**, the snapshot size is **50 GiB**, and you are billed for 50 GiB.
* **Subsequent Snapshots (Incremental Backup):** Subsequent snapshots are incremental. They only save blocks that have changed or been added since the last snapshot.
    * *Cost Calculation:* Continuing the example above, if you change **20 GiB** of data and add **10 GiB** of new data, the next snapshot will be **30 GiB** in size. You are billed for the additional 30 GiB.
* **Deletion Logic:** Deleting a snapshot only removes data unique to that snapshot. Blocks referenced by other snapshots are retained.

### Best Practices
* Use AWS Backup or automated scripts for regular snapshots.
* Stop the instance or detach the volume to ensure data consistency before snapshotting.
* Tag snapshots for organization and use lifecycle policies to automate deletion.
<img width="776" height="382" alt="image" src="https://github.com/user-attachments/assets/85f32413-cf38-4230-941d-604f58f53eaa" />

---

## 4. AMI Management: Encryption and Sharing
Amazon Machine Images (AMIs) can be copied and encrypted to meet compliance and security requirements.

### AMI Encryption Workflow
You cannot directly enable encryption on an existing unencrypted AMI or Snapshot. instead, you must:
1.  Select the source AMI.
2.  Initiate a **Copy AMI** process (to the same or a different region).
3.  Select the **Encrypt** option and choose an AWS KMS key.
4.  This process is also used to **re-encrypt** an already encrypted AMI with a different key.
<img width="974" height="360" alt="image" src="https://github.com/user-attachments/assets/eaeeab33-9088-4685-a0d2-da2e3ff221fe" />

### Sharing Encrypted AMIs Across Accounts
Sharing encrypted AMIs is more complex than sharing unencrypted ones because the target account needs access to both the AMI and the encryption key.

1.  **Prerequisites:** You must own the custom Customer Managed Key (CMK) used to encrypt the AMI. **You cannot share AMIs encrypted with the default AWS-managed key.**
2.  **Step 1 (KMS Key Policy):** Modify the Key Policy of the KMS key in the source account to allow the target account to use it.
3.  **Step 2 (AMI Permissions):** Modify the AMI permissions to share the AMI with the target account ID.
4.  **Step 3 (Snapshot Permissions):** Share any associated snapshots with the target account.
5.  **Target Account Limitations:** The target account can create volumes and instances from the shared AMI but **cannot re-share** the AMI with others.
<img width="752" height="311" alt="image" src="https://github.com/user-attachments/assets/2db1b6f7-0a1e-4e45-bb7a-20c9d30f8624" />

---

## 5. EC2 Image Builder
EC2 Image Builder is a fully managed service that automates the creation, management, and deployment of customized server images ("Golden Images").

### Challenges with Manual Processes
* **High Operational Overhead:** Manually patching and updating images is time-consuming.
* **Inconsistency:** Manual builds may miss security patches or configuration standards.
* **Scaling Difficulty:** Distributing images across multiple regions and accounts usually requires complex custom scripting (e.g., using Packer).

### Image Builder Pipeline Components
The service uses a pipeline approach to solve these issues:
1.  **Image Recipe:** Defines the source image (e.g., base Linux/Windows) and the build components (software, agents, scripts).
2.  **Infrastructure Configuration:** Specifies the environment where the image is built (Instance Type, Subnet, Security Groups).
3.  **Distribution Configuration:** Defines where the final image should be sent (specific AWS Regions and Accounts).
4.  **Schedule:** Automates when the pipeline runs (e.g., weekly or whenever the source image updates).
5.  **Cascading Pipelines:** You can chain pipelines together. for example, a "Base Security Pipeline" produces a secured image, which then triggers a "Web Server Pipeline" and a "Database Pipeline" to add workload-specific software.
<img width="1063" height="315" alt="image" src="https://github.com/user-attachments/assets/1766a7e8-367a-44b5-8760-1c2ec7cbe14d" />

---

## 6. AWS Load Balancing
Load balancers distribute incoming traffic across multiple targets to ensure application availability, scalability, and security.

### Application Load Balancer (ALB)
* **Layer:** Operates at **Layer 7** (Application Layer - HTTP/HTTPS).
* **Routing:** Supports advanced routing based on content, such as **Path-based routing** (e.g., `/images`, `/api`) and **Host-based routing** (e.g., `api.example.com`).
* **Target Groups:** Can route to EC2 instances, IP addresses, and Lambda functions.
* **Key Features:**
    * **Stickiness:** Uses application cookies to bind a user session to a specific server.
    * **Microservices:** Ideal for container-based applications (ECS/EKS).
    * **redirects:** Can handle HTTP to HTTPS redirects and fixed responses.

### Network Load Balancer (NLB)
* **Layer:** Operates at **Layer 4** (Transport Layer - TCP/UDP/TLS).
* **Performance:** Designed for ultra-high performance and low latency. Capable of handling millions of requests per second.
* **Key Features:**
    * **Static IP:** Can provide a static IP address for the application.
    * **ALB as a Target:** An NLB can route traffic to an ALB. This architecture combines the static IP benefit of the NLB with the Layer 7 routing capabilities of the ALB.

### Gateway Load Balancer (GWLB)
* **Layer:** Operates at **Layer 3** (Network Layer).
* **Use Case:** Used to deploy, scale, and manage third-party virtual appliances such as firewalls, Intrusion Detection Systems (IDS), and Deep Packet Inspection (DPI) systems.
* **Protocol:** Uses the **GENEVE** protocol to encapsulate and route traffic to appliances transparently.
