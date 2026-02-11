
# Q1. Create an ECR Repository and Push a Docker Image

## ✅ Problem
Create a private ECR repository named `lab-repo-<ACCOUNT_ID>` in `us-west-2`, build a Docker image, and push it to ECR.

---

## 🧭 Steps to Solve

### 1. Create ECR Repository
Run the following command in the CLI:
```bash
aws ecr create-repository \
  --repository-name lab-repo-<ACCOUNT_ID> \
  --region us-west-2
````

---

### 2. Create a Dockerfile

Open the Dockerfile using `vi` with sudo privileges:

```bash
sudo vi Dockerfile
```

Password: `user@123!`

Add the following content inside the file (replace `<ACCOUNT_ID>` with your actual AWS account ID):

```dockerfile
FROM alpine:3.18
CMD ["echo", "Hello from lab-repo-<ACCOUNT_ID>!"]
```

Save and exit the file (`:wq` in vi).

---

### 3. Authenticate Docker to ECR

Authenticate Docker with your AWS ECR registry:

```bash
aws ecr get-login-password --region us-west-2 \
  | sudo docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com
```

---

### 4. Build the Docker Image

Build the Docker image using `sudo`:

```bash
sudo docker build -t lab-repo-<ACCOUNT_ID> .
```

---

### 5. Tag the Image

Tag the image for ECR:

```bash
sudo docker tag lab-repo-<ACCOUNT_ID>:latest <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lab-repo-<ACCOUNT_ID>:latest
```

---

### 6. Push the Image to ECR

Push the image to the ECR repository:

```bash
sudo docker push <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lab-repo-<ACCOUNT_ID>:latest
```

---

### 7. Verify the Upload

Go to the AWS Management Console → **ECR** → **Repositories** → `lab-repo-<ACCOUNT_ID>`
Check that the **latest** tag appears successfully.

---

## 🧾 Example Output

```
Repository URI: <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/lab-repo-<ACCOUNT_ID>
Image Tag: latest
Image successfully pushed to ECR.
```

---
---

# AWS ECR Task: Create Repository, Push Docker Images, and Apply Lifecycle Policy

## 🎯 Objective
Provision a **private ECR repository** in `us-west-2` named `lab-repo-<ACCOUNT_ID>-lifecycle`, enable **image scanning on push**, apply a **lifecycle policy** to retain only the **most recent image**, build and push two Docker image versions (v1 then v2), and verify that after pushing v2, only v2 remains.  

All Docker commands must be executed as **root using sudo**.

---

## 1️⃣ Step 1: Set Variables
Replace `<ACCOUNT_ID>` with your actual AWS Account ID (`345376996746`):

```bash
ACCOUNT_ID=345376996746
REGION=us-west-2
REPO_NAME=lab-repo-$ACCOUNT_ID-lifecycle
```

---

## 2️⃣ Step 2: Create ECR Repository with Scan on Push

```bash
aws ecr create-repository \
  --repository-name $REPO_NAME \
  --region $REGION \
  --image-scanning-configuration scanOnPush=true
```

✅ This will:

* Create the repository
* Enable **scan on push** (automatic vulnerability scanning for new images)
* Apply default encryption (`AES256`) and mutability (`MUTABLE`)

---

## 3️⃣ Step 3: Apply Lifecycle Policy

### 3a. Create `lifecycle-policy.json`

```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Retain only the most recent image",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

### 3b. Apply Policy

```bash
aws ecr put-lifecycle-policy \
  --repository-name $REPO_NAME \
  --lifecycle-policy-text file://lifecycle-policy.json \
  --region $REGION
```

✅ This ensures **only the most recent image is retained**.

---

## 4️⃣ Step 4: Prepare Dockerfile

### 4a. Create Dockerfile for v1

```bash
sudo vi Dockerfile
```

Add the following content:

```dockerfile
FROM alpine:3.18
RUN apk add --no-cache curl
CMD ["sh", "-c", "echo Scanning ECR!"]
```

Save and exit (`:wq` in vi).

---

## 5️⃣ Step 5: Authenticate Docker to ECR

```bash
aws ecr get-login-password --region $REGION \
  | sudo docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
```

✅ Output should be:

```
Login Succeeded
```

---

## 6️⃣ Step 6: Build, Tag, and Push Docker Images

### 6a. Build v1 image

```bash
sudo docker build -t $REPO_NAME --build-arg VERSION=v1 .
```

### 6b. Tag v1 for ECR

```bash
sudo docker tag $REPO_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:v1
```

### 6c. Push v1 to ECR

```bash
sudo docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:v1
```

---

### 6d. Modify Dockerfile for v2

```bash
sudo vi Dockerfile
```

Update CMD line:

```dockerfile
FROM alpine:3.18
RUN apk add --no-cache curl
CMD ["sh", "-c", "echo Scanning ECR! v2"]
```

---

### 6e. Build v2 image

```bash
sudo docker build -t $REPO_NAME --build-arg VERSION=v2 .
```

### 6f. Tag v2 for ECR

```bash
sudo docker tag $REPO_NAME:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:v2
```

### 6g. Push v2 to ECR

```bash
sudo docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:v2
```

✅ After this, the **lifecycle policy** should expire the older `v1` image automatically.

---

## 7️⃣ Step 7: Preview Lifecycle Policy

### 7a. Start preview

```bash
aws ecr start-lifecycle-policy-preview \
  --repository-name $REPO_NAME \
  --region $REGION
```

### 7b. Check preview results

```bash
aws ecr get-lifecycle-policy-preview \
  --repository-name $REPO_NAME \
  --region $REGION \
  --query 'previewResults[].imageTags'
```

✅ Expected output:

```json
[
    ["v1"]
]
```

* `v1` should appear as **candidate for expiration**, `v2` remains.

---

## 8️⃣ Notes & Tips

* Always use `sudo` for Docker commands if root access is required.
* Make sure **lifecycle policy** is applied **before pushing multiple versions** to test automatic cleanup.
* `scanOnPush=true` ensures every pushed image is scanned automatically.
* Tagging images properly (`v1`, `v2`) is crucial for lifecycle policies to work.

---

## 9️⃣ Optional: Verify Images in ECR

```bash
aws ecr list-images \
  --repository-name $REPO_NAME \
  --region $REGION
```

✅ Should show only the **latest image** (`v2`) after lifecycle policy runs.

---

This workflow ensures your repository is correctly configured with **scan-on-push**, **lifecycle policy**, and **two versioned images**.

```

---
```

---

```
