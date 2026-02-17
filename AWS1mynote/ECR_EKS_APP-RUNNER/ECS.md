
---

## 1. Core Architecture & Components

Amazon ECS is a container orchestration service that consists of several key components working together to run applications.

* **Clusters**: A logical grouping of infrastructure resources (EC2 instances or Fargate) where containers run. They provide isolation between workloads and can span multiple Availability Zones within a region.


* **Task Definitions**: A blueprint or immutable specification that describes how a container should be launched. It defines the image, CPU, memory, ports, and volumes required.

* **Images and ECR**: Images are stored in Amazon Elastic Container Registry (ECR). ECS pulls the container images from the registry to deploy them based on task definitions.

* **Tasks**: These are running instances of a task definition within a cluster. Tasks are ephemeral and can be created or terminated based on application requirements.


* **Services**: A configuration that maintains a specified number of task instances simultaneously. It provides features like load balancing, auto-scaling, and rolling updates for long-running applications.


* **Nodes**: The EC2 instances that host containers and are part of the ECS cluster. They run the ECS container agent to manage task life cycles.


* **Namespace**: A logical boundary used for service discovery within AWS Cloud Map. It allows containers to connect via DNS or API calls without using hardcoded IPs.

<img width="948" height="567" alt="image" src="https://github.com/user-attachments/assets/760a6f4c-fe20-4cd8-b67e-e39ebe40f3bd" />


---

## 2. Launch Types: EC2 vs. Fargate

ECS offers two primary deployment options, each catering to different management and control needs.

### EC2 Launch Type

* **Management**: The user is responsible for managing the EC2 instances.


* **Control**: Offers more granular control over the underlying infrastructure.


* **Cost**: Supports the use of Spot Instances for cost savings.


* **Customization**: Provides support for custom AMIs and access to instance-level features.



### Fargate Launch Type

* **Serverless**: A serverless compute engine that eliminates the need to provision or manage servers.


* **Operational Focus**: Allows teams to focus on building applications rather than managing infrastructure.


* **Cost**: Users pay only for the resources consumed by the containers.


* **Scaling & Security**: Offers automatic scaling without infrastructure management and enhanced security isolation.



---

## 3. Deployment Strategies

ECS provides multiple strategies to update services with minimal disruption.

* **Rolling Update**: The default strategy that gradually replaces current tasks with updated versions. It minimizes downtime using configurable parameters like "minimum healthy percent".


* **Blue/Green**: Runs two identical environments (blue and green) and switches traffic all at once. It is implemented using AWS CodeDeploy and allows for easy rollbacks if issues occur.
* **Canary**: Shifts a small percentage of traffic to the new version before a full deployment. This allows testing with a subset of users and uses configurable traffic shifting intervals.

---

## 4. Interview Focus: Moving from App Runner to ECS

Understanding when to transition from AWS App Runner to ECS is a key architectural decision.

### Limitations of App Runner

* **Scaling**: It is limited to 25 concurrent instances.


* **Control**: Offers less granular scaling controls and fixed scaling thresholds.


* **Customization**: Lacks support for custom scaling metrics.


* **Networking**: Has networking and VPC constraints that may not meet complex application needs.



### Why Choose ECS?

* ECS should be used when an application requires more than 25 instances or complex scaling logic.


* It is necessary for applications requiring deep VPC integration or extensive networking customization.


* ECS provides the flexibility needed for highly customized container environments that App Runner cannot support.



---
