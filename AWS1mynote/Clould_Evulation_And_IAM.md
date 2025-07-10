# Day 153 - Cloud Computing Basics, Analogy, and Evolution

## 🧠 Topics Covered

### 1. Introduction to Cloud Computing
- Journey since 2005: AWS, Azure, Google Cloud, IBM Cloud, Alibaba Cloud
- Evolution from on-prem to cloud
- Analogy: Electricity Grid (On-demand usage)

### 2. Cloud Offerings
---
1. **Public Cloud**

   * **Accessible to all** (shared infrastructure).
   * Ideal for general-purpose use.
   * Examples: **AWS**, **Google Cloud Platform (GCP)**, **Microsoft Azure**.
   * Tagline: *"Cloud for everyone."*

2. **Private Cloud**

   * **Dedicated hosting** (no sharing).
   * Used by organizations that require full control, security, and compliance.
   * Example: **SBI using Meghdoot Cloud** (Meghdoot is their private cloud solution).

3. **Hybrid Cloud**

   * **Mix of Public + Private Clouds**.
   * Suitable for organizations managing sensitive data and large-scale operations.
   * Example: **SBI using four cloud providers**.

     * Due to **expansion plans** and **EU regulations**, they opted to include **public cloud** in their architecture.

---



### 3. AWS Core Services
- **VPC**: Virtual Private Cloud
- **S3**: Simple Storage Service
- **IAM**: Identity & Access Management
- **RDS**: Relational Database Service
- **CloudWatch**: Monitoring
- **EKS**: Elastic Kubernetes Service
- **ECS**: Elastic Container Service
- **SNS / SQS**: Notifications & Messaging Queues

### 4. Generative AI in AWS
- **Amazon Bedrock**
- **LLMOps**: Ops for LLM-based applications

### 5. Career Tracks in Cloud
- **Infra Developer**: BD, PM, SMEs
- **Inside Sales**
- **DevOps / DataOps / MLOps**
- **Cloud Engineers**: S3, IAM, RDS, Lambda, ECR, DynamoDB, Cognito, Kafka, etc.

### 6. Foundational Knowledge
- AWS Regions & Availability Zones
  - Example: Mumbai (ap-south-1)
- Networking & Security

---

## 📌 Key Concepts

- **Cloud is like electricity**: Pay for what you use
- **Scalability**: No upfront hardware
- **Cost-effectiveness**: Pay-as-you-go model
- **Accessibility**: Global access, multi-region
- **Security**: Shared responsibility model

---
## 🚀 Tips for Learners
- Understand AWS console navigation
- Get hands-on with services like S3, IAM, and RDS
- Explore Bedrock & GenAI services for the future
# AWS Regions and Availability Zones

##   Regions

* AWS Regions are separate geographic areas that host multiple Availability Zones to provide high availability and fault tolerance.

##   Availability Zone (AZ)

* An AZ is a physically isolated data center within a region, connected through low-latency links for high availability.

##   Edge Locations

* Edge Locations are endpoints in the AWS global network used by Amazon CloudFront (a content delivery network) and Amazon Route 53 (a DNS service) to cache content closer to users, which reduces latency.

##   Local Zone

* Local Zones extend AWS services closer to large population centers for ultra-low latency use cases like gaming and video editing. 

##   Outpost

* AWS Outposts bring AWS infrastructure and services to on-premises locations for a consistent hybrid experience.

##   Wavelength

* AWS Wavelength embeds compute and storage services at telecom providers' 5G networks for ultra-low latency applications.

#   IAM (Identity & Access Management)

* An AWS Identity and Access Management (IAM) user is an entity that you create in AWS to represent the person or application that uses it to interact with AWS Services.
   
* AWS Identity and Access Management (IAM) is a web service that helps you securely control access to AWS resources.
   
* IAM helps protect against security breaches by allowing administrators to automate numerous user account-related tasks.
   
* Best practice: Use the root user only to create your first IAM user.
   
* Enable Multi-Factor Authentication (MFA) for the Root User (e.g., using Google Authenticator for Virtual MFA).

##   Best Practices

* It is strongly recommended that you do not use the "root user" for your everyday tasks, even the administrative ones.
   
* Instead, adhere to the best practice of using the root user only to create your first IAM user.
   
* IAM user is truly global, i.e., once an IAM user is created, it can be accessible in all the regions in AWS.
   
* Amazon S3 is also considered global, but it is not truly global.
   
* When we create a bucket in S3, it displays all the buckets of other regions in one place, so that is the reason we are calling Amazon S3 Global (but partly global).
   
* But IAM is 100% Global. Once you create an IAM user, you can use it anywhere in all the regions.

##   Key IAM Components

* Main things in IAM:
   * Roles
   * Users
   * Policies / Permissions
   * Groups
* IAM users can be accessed in the following 3 ways:
   * AWS Console
   * CLI (Command Line Interface)
   * API 
* In MNCs, permissions will not be provided for individual users. Create the Groups and add the users to them.
* Users & Groups are for the End users. 
* Roles are for the AWS Services. 

##   IAM User Creation Steps

1.  Create an IAM user:
    * Services → Security, Identity, & Compliance → IAM → Users → Add user
    * User name: Iamuser1
    * Access type: Select both "Programmatic Access" and "AWS Management Console access"
    * Console password: Select "Custom Password" and set a password
    * Click "Next: Permissions" (Note: we are not providing any permissions as of now, just create user)
    * Once the IAM user has been created, you will see AccessKeyID and SecretAccessKey.  (Note: Once you close this window, AccessKeyID and SecretAccesskey are gone, so save it somewhere)
2.  Group Creation:
    * Create new group
    * Group name = admins (Note: no need to add any policy now)
    * Create group
3.  Add user to this group:
    * Click on the newly created group 'admins'
    * Add users to Group
    * GroupARN = arn:aws:iam:: 540105522204:group/admins
    * Always add the permissions to the 'Groups' level, not to the 'users' level.
    * It's a Best Practice in the real-time.

##   Policies

* When we want to add the permissions to the groups, it is through the 'Policies'.
* Default AWS Policies appear in 'Orange color Icons'.
* One disadvantage of AWS Default Policies is that we can't customize the policies to apply to the Groups. 
* To provide customized policies to apply to Groups, we need to create a new one and apply it to the Groups.
* Now, we will add 'Administrator Access' Permissions to the user (Iamuser1) we created.
* Groups - Admins - tab  permissions - AttachPolicy - select AdministratorAccess - AttachPolicy
* Dashboard: Customize the IAM sign-in link by replacing the ID with any name to hide the ID.
    * Before Customize: <https://4234324234.signin.aws.amazon.com/console>
    * After Customize: <https://classroomuser.signin.aws.amazon.com/console>
* Open the new tab in the browser
    * <https://classroomuser.signin.aws.amazon.com/console>
    * IAM user: Iamuser1
    * password=test1234
* Now, log in using the IAM user we created. [
* Once logged in, we can launch an EC2 instance, as this user (Iamuser1) is provided with Admin access.

##   Requirement: Create a new user with specific permissions

* Requirement: Create a new user and he should be able to only 'stop', 'start', 'reboot', and select instances.
* He should not have the permissions to terminate the EC2 Instances. 
* He should not have the permissions to create the new EC2 Instance. 
1.  Log in to your AWS Console with your root login.
2.  IAM - Create another user
    * User name: Iamuser2
    * Access Type: Select "AWS Management Console access"
    * Select Custom Password = "<somepassword>"
    * Next: Permissions (Not selecting any group here)
    * Create user
3.  Sign out and log in using the 'Iamuser2' credentials
    * Open browser: <https://classroomuser.signin.aws.amazon.com/console>
    * Log in with Iamuser2 credentials
4.  Services → EC2: You will get an 'Authorization Error'. To view EC2 instances, you need to provide read permission to the user 'Iamuser2'. 
5.  Using Tags, we can provide permissions to this user.
    * Log in using the Root user
    * EC2 Instances
    * Select the Running Instance
    * Click on the tab
    * Add a new tag: Key = user, Value = Iamuser2
    * Save
6.  We can restrict the user to create EC2 instances and allow him to do only 'stop' and 'start' Instances by writing custom scripts.
    * Open the browser and search for 'restrict aws user ec2 instance'
    * <https://aws.amazon.com/premiumsupport/knowledge-center/restrict-ec2-iam/>
    * Copy the script and open it in any editor and customize it.
    * arn:aws:ec2:us-east-1:111122223333:instance/*" (Note: For every service, we have ARN (Amazon Resource Name), but for EC2, there is no ARN naming)
    * Interview Question: If anyone asks you, "ARN is not displaying for the EC2 instances?"
    * Ans: Simply say that ARN is not visible for the EC2 instances, but for the other services like S3, we have ARN URL.
    * Copy the script
    
    ```json
    {
    "Version": "2012-10-17",
    "Statement": \[
    {
    "Action": \[
    "ec2: StartInstances",
    "ec2: StopInstances",
    "ec2: RebootInstances"
    \],
    "Condition": {
    "StringEquals": {
    "ec2: ResourceTag/Owner": "Bob"
    }
    },
    "Resource":\[
    "arn:aws:ec2:us-east-1:111122223333:instance/*"
    \],
    "Effect": "Allow"
    },
    {
    "Effect": "Allow",
    "Action": "ec2: Describe\*",
    "Resource": "\*"
    }
    \]
    }
    ```
    
    * After Customization
    
    ```json
    {
    "Version": "2012-10-17",
    "Statement": \[
    {
    "Action": \[
    "ec2: StartInstances",
    "ec2: StopInstances",
    "ec2: RebootInstances"
    \],
    "Condition": {
    "StringEquals": {
    "ec2: ResourceTag/user": "Iamuser2"
    }
    },
    "Resource": \[
    "arn:aws:ec2:us-east-1:449938344550: instance/*"
    \],
    "Effect": "Allow"
    },
    {
    "Effect": "Allow",
    "Action": "ec2: Describe\*",
    "Resource": "\*"
    }
    \]
    }
    ```
    
    * Note:
    
    ```
    "Action": "ec2: Describe\*",
    "Resource": "\*"
    449938344550  Root AccountID
    ```
7.  Copy the script after customization
    * IAM User
    * Policies → CreatePolicy → Select JSON tab
    * Paste the customized script.
8.  Review Policy
    * Name 'UserRestrictEC2Instance'
9.  Review Policy → create policy
10. Now, add this policy to the user or groups.
    * Select Users → 'Iamuser2' → Permissions (tab) → Add Permissions → Attach existing policies directly
    * Filter policies = 'UserRestrictEC2Instance'
    * Select the policy ('UserRestrictEC2Instance') → Review → AddPermissions 
11. Log in to the IAM user console
    * Iamuser2/password
12. Now, try to Terminate the EC2 Instance. 
13. It throws an error. 
14. Try to Launch an EC2 instance, it throws an error.
15. Like this, we can restrict the user by creating some policies and applying them. 
16. AWS provides the ready-made (default) policies; we need to customize them as per our requirement.

You're looking at a configuration page for **Centralized Root Access** in AWS Organizations (or similar AWS service governance tooling). Here's a breakdown of the sections and what your options mean:

---

### 🔐 **Centralized Root Access Overview**

This feature allows the **management account** (or optionally a delegated admin account) to manage **root-level credentials** and perform **privileged actions** across **member accounts** in an AWS Organization.

---

### ⚙️ **Available Features Explained**

#### 1. **Root Credentials Management**

* ✅ **Enabled**: You can view, delete, and audit **root credentials** (email/passwords, MFA, recovery questions) of member accounts.
* 🔄 You can **disable** it if you don’t want centralized visibility/control over those credentials.
* 📌 **Optional Feature**: Allow **password recovery** for specific accounts centrally.

#### 2. **Privileged Root Actions in Member Accounts**

* ✅ **Enabled**: This lets you execute certain high-privilege root-only actions **remotely**, like:

  * Deleting misconfigured **Amazon S3** or **Amazon SQS** policies.
  * Resetting some service configurations that normally require root access.

#### 3. **Delegated Administrator for Centralized Root Access**

* 🔧 You can **assign** a member account (other than the management account) to act as a **delegated administrator**. This account will then be authorized to perform all root access functions for other member accounts.

---

### 🔄 **What You Can Do Now**

* If you want to **turn off centralized root control**, click **"Disable"** next to each feature.
* If you want to **allow another account to manage root access**, click **"Assign"** under **Delegated administrator** and select the desired member account.

---

### ⚠️ **Important Considerations**

* Root access is extremely powerful — centralizing it can reduce risk through auditing and governance, but it **also concentrates power**, so:

  * **Use MFA** on the management and delegated admin accounts.
  * **Audit access logs** regularly (via CloudTrail).
  * Only assign delegated access to **high-trust internal accounts**.




