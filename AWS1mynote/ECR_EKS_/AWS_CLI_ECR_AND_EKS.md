
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

**✅ Final Check:**

* ECR repository created
* Docker image built and pushed successfully
* `latest` tag visible in AWS ECR console

```

---

```
