# Terraform MCQ Questions - Comprehensive Assessment

## Question 1: Basic Commands
Which command is used to initialize a Terraform working directory?

A) `terraform start`
B) `terraform init`
C) `terraform begin`
D) `terraform setup`

**Correct Answer: B) `terraform init`**

---

## Question 2: Basic Commands
What does the `terraform plan` command do?

A) Applies the configuration changes
B) Destroys all resources
C) Shows what actions Terraform will take without making changes
D) Validates the syntax only

**Correct Answer: C) Shows what actions Terraform will take without making changes**

---

## Question 3: State Management
Where is the Terraform state file stored by default?

A) In the cloud provider
B) In a remote backend
C) Locally in the working directory as `terraform.tfstate`
D) In the `.terraform` folder

**Correct Answer: C) Locally in the working directory as `terraform.tfstate`**

---

## Question 4: State Management
Which command is used to list all resources in the Terraform state?

A) `terraform show`
B) `terraform list`
C) `terraform state list`
D) `terraform resources`

**Correct Answer: C) `terraform state list`**

---

## Question 5: Variables
How do you define a variable with a default value in Terraform?

A) `variable "name" { default = "value" }`
B) `var "name" = "value"`
C) `define name = "value"`
D) `set variable name "value"`

**Correct Answer: A) `variable "name" { default = "value" }`**

---

## Question 6: Variables
Which file extension is commonly used for Terraform variable definitions?

A) `.tf`
B) `.tfvars`
C) `.var`
D) Both A and B

**Correct Answer: D) Both A and B**

---

## Question 7: Data Sources
What is the purpose of data sources in Terraform?

A) To create new resources
B) To fetch information about existing resources
C) To store variables
D) To define providers

**Correct Answer: B) To fetch information about existing resources**

---

## Question 8: Data Sources
Which keyword is used to define a data source in Terraform?

A) `resource`
B) `data`
C) `source`
D) `fetch`

**Correct Answer: B) `data`**

---

## Question 9: Providers
What is a provider in Terraform?

A) A plugin that manages resources for a specific service
B) A variable definition
C) A state file
D) A configuration file

**Correct Answer: A) A plugin that manages resources for a specific service**

---

## Question 10: Providers
Which block is used to configure provider settings?

A) `terraform { }`
B) `provider { }`
C) `config { }`
D) `settings { }`

**Correct Answer: B) `provider { }`**

---

## Question 11: Version Constraints
Which symbol is used to specify "greater than or equal to" in version constraints?

A) `>`
B) `>=`
C) `=>`
D) `>>`

**Correct Answer: B) `>=`**

---

## Question 12: Version Constraints
What does the version constraint `~> 1.2` mean?

A) Exactly version 1.2
B) Any version greater than 1.2
C) Version 1.2 or higher, but less than 2.0
D) Any version in the 1.x series

**Correct Answer: C) Version 1.2 or higher, but less than 2.0**

---

## Question 13: Remote State
Which backend is commonly used with AWS for remote state storage?

A) Local
B) HTTP
C) S3
D) FTP

**Correct Answer: C) S3**

---

## Question 14: State Locking
What is the primary benefit of state locking in Terraform?

A) Faster execution
B) Better security
C) Prevents concurrent modifications that could corrupt state
D) Reduces file size

**Correct Answer: C) Prevents concurrent modifications that could corrupt state**

---

## Question 15: Workspaces
Which command creates a new Terraform workspace?

A) `terraform workspace new <name>`
B) `terraform create workspace <name>`
C) `terraform new workspace <name>`
D) `terraform workspace create <name>`

**Correct Answer: A) `terraform workspace new <name>`**

---

## Answer Key Summary:
1. B - `terraform init`
2. C - Shows what actions Terraform will take without making changes
3. C - Locally in the working directory as `terraform.tfstate`
4. C - `terraform state list`
5. A - `variable "name" { default = "value" }`
6. D - Both A and B
7. B - To fetch information about existing resources
8. B - `data`
9. A - A plugin that manages resources for a specific service
10. B - `provider { }`
11. B - `>=`
12. C - Version 1.2 or higher, but less than 2.0
13. C - S3
14. C - Prevents concurrent modifications that could corrupt state
15. A - `terraform workspace new <name>`