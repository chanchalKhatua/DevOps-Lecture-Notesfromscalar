# 🧠 AWS Storage & Website Hosting using S3, Amplify & CloudFront

## 📅 Agenda
- Overview of AWS Storage Services  
- Different Storage Types  
- Introduction to Amazon S3  
- S3 Storage Classes  
- Lifecycle Policies  
- S3 Bucket Types (Generic & Advanced)  
- Encryption in S3  
- Event Notifications  
- Hosting a Website using:
  - S3 (Static Website)
  - Amplify
  - CloudFront  
- GitOps Integration with S3 Hosting  

---

## 🏁 Background

### 📖 The Beginning  
**March 14, 2006** – Amazon **S3 (Simple Storage Service)** became the **first AWS service ever launched**, revolutionizing how data storage works.

---

## ☁️ What is Object Storage?

Object storage manages data as **objects** instead of files or blocks.  
Each object contains:
- The data itself
- Metadata
- A unique identifier

It is best suited for:
- Unstructured data (images, videos, audio, backups, logs)
- Scalability and distributed storage
- Cloud-native applications
- Analytics and archival purposes  

🔗 Reference: [AWS S3 Official Page](https://aws.amazon.com/s3/)

---

## 💾 Types of AWS Storage Services

| Type | Example Service | Description |
|------|------------------|-------------|
| Object Storage | **Amazon S3** | Stores unstructured data as objects |
| Block Storage | **Amazon EBS (Elastic Block Store)** | Used for EC2 instances (like virtual hard drives) |
| File Storage | **Amazon EFS (Elastic File System)** | Shared file storage for EC2 instances |
| Archival Storage | **Amazon S3 Glacier** | Long-term, low-cost cold storage |
| Hybrid / Edge | **AWS Storage Gateway** | Connects on-premise storage with cloud |
| Backup | **AWS Backup** | Centralized backup management |

---

## 🪣 Introduction to Amazon S3

**Amazon Simple Storage Service (S3)** offers:
- Industry-leading **scalability, durability, and availability**
- **Security and performance**
- **Storage for any use case:** Data lakes, mobile apps, websites, and backups
- **Cost optimization** with various storage classes
- **Access control** and **fine-tuned permissions**

---

## 🧩 S3 Use Cases

- Data backup and archiving  
- Static website hosting  
- Big data analytics storage  
- Data lake foundation  
- Media storage and distribution  
- Disaster recovery  
- Application asset hosting  

---

## 🧱 S3 Storage Classes

| Storage Class | Description | Ideal Use |
|----------------|--------------|------------|
| **S3 Standard** | High durability, availability | Frequently accessed data |
| **S3 Intelligent-Tiering** | Automatically moves data between access tiers | Unknown or changing access patterns |
| **S3 Standard-IA (Infrequent Access)** | Low-cost for infrequently accessed data | Backups, disaster recovery |
| **S3 One Zone-IA** | Lower cost, stored in one AZ | Re-creatable or non-critical data |
| **S3 Glacier Instant Retrieval** | Archive with millisecond access | Long-term data needing fast retrieval |
| **S3 Glacier Flexible Retrieval** | Standard archival with retrieval in minutes/hours | Archival storage |
| **S3 Glacier Deep Archive** | Lowest cost, hours retrieval | Long-term archival |
| **S3 Express One Zone** | High-performance single AZ | Latency-sensitive workloads |

---

## ⏳ S3 Lifecycle Policies

Lifecycle policies help **automate data transitions** between storage classes to **reduce costs**.

**Examples:**
- Move files older than 30 days to *Standard-IA*
- Archive files after 180 days to *Glacier*
- Delete logs older than 1 year

---

## 🪣 S3 Bucket Creation via AWS Console

Steps:
1. Open AWS S3 Console  
2. Click **Create Bucket**  
3. Choose:
   - **Bucket name**
   - **Region**
   - **Versioning**
   - **Encryption**
4. Set **permissions** (public or private)
5. Upload and manage objects

---

## 🧩 Bucket Types

### **Generic Buckets**
- Standard S3 buckets for general-purpose storage.

### **Advanced / Vector Buckets**
Used for storing **embeddings or vectorized data** for **AI & semantic search**.

#### 🧠 What is a Vector DB?
A vector database stores data as mathematical vectors, enabling **semantic search**—it interprets **meaning** rather than exact keywords.

---

## 🔒 Encryption in S3

| Encryption Type | Description |
|------------------|-------------|
| **SSE-S3** | Managed by AWS (default server-side encryption) |
| **SSE-KMS** | Uses AWS KMS for key management and auditing |
| **SSE-C** | Customer provides and manages encryption keys |
| **Client-Side Encryption** | Data encrypted before upload |

---

## 📣 Event Notifications

S3 can trigger events on object actions:
- `PUT`, `DELETE`, or `COPY` operations  
Can be sent to:
- **Amazon SNS**
- **Amazon SQS**
- **AWS Lambda**

**Example:**  
Trigger a Lambda when a new file is uploaded for processing or resizing.

---

## 📊 S3 Recap

- **Durability:** 99.999999999% (11 nines)  
- **Availability:** 99.99% for S3 Standard  
- **Strong Consistency** for all operations  
- **Security:** IAM policies, MFA Delete, encryption options  
- **Replication:** Cross-Region (CRR) & Same-Region (SRR)  
- **Lifecycle management** for cost optimization  
- **Integration:** Works with Athena, Redshift, Glue for analytics  
- **Performance:** Supports thousands of requests per second  

---

## 🌐 Hosting a Website using S3

### **Method 0:** Direct Hosting
- Enable “Static Website Hosting” in S3
- Upload HTML/CSS/JS files
- Make the bucket public
- Use the S3 website endpoint

### **Method 1:** Using AWS Amplify
- Simplifies web app deployment and CI/CD
- Integrates with GitHub / GitLab
- Provides automatic builds and HTTPS

### **Method 2:** Using CloudFront
- Adds **CDN caching** and **HTTPS**
- Distributes content globally with low latency
- Secures S3 via Origin Access Control (OAC)

---

## 🌍 Amazon CloudFront

### **Overview**
A **Content Delivery Network (CDN)** that delivers web content globally via **edge locations**.

### **How It Works**
1. User requests content from CloudFront.
2. If cached at an edge location → served instantly.  
3. If not cached → fetched from S3 or origin server and cached.

### **Benefits**
- Faster content delivery
- Global scalability
- HTTPS & security (TLS)
- Integrates with S3, EC2, Load Balancers, or custom origins

---

## ⚙️ CloudFront + S3 Architecture

1. S3 Bucket stores static assets (HTML, CSS, JS, images)  
2. CloudFront retrieves and caches data  
3. Users access via CloudFront’s domain for low latency  
4. (Optional) Route 53 used for domain routing  

---

## 🚀 GitOps and S3 Hosting

**GitOps** automates deployment to S3 and Amplify via Git repositories.

- Push code to main branch → triggers CI/CD pipeline  
- AWS Amplify or CodePipeline deploys latest site version automatically  
- Enables **version control**, **rollback**, and **automation**

---

## 🧾 Final Summary

- Amazon S3 = Object Storage Backbone of AWS  
- Multiple storage classes = Cost flexibility  
- Lifecycle & encryption = Efficiency + Security  
- CloudFront = Speed & Global Reach  
- Amplify = Simplified Hosting Automation  
- GitOps = Continuous Deployment to S3  
