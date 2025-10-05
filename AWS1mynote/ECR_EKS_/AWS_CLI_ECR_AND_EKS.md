ECR and Docker CLI Commands
A collection of the CLI commands needed to create an ECR repository and push a Docker image to it.

1. Get Your AWS Account ID
This command retrieves your 12-digit AWS Account ID.

aws sts get-caller-identity --query Account --output text

2. Create the ECR Repository
This command creates a new private ECR repository.

aws ecr create-repository --repository-name lab-repo-<ACCOUNT_ID> --region us-west-2

3. Create the Dockerfile
Use a text editor like vi to create the Dockerfile.

sudo vi Dockerfile

Dockerfile Content:

FROM alpine:3.18
CMD ["echo", "Hello from lab-repo-<ACCOUNT_ID>!"]

4. Authenticate Docker to ECR
This command retrieves an authentication token and logs the Docker client into your ECR registry.

aws ecr get-login-password --region us-west-2 \
  | sudo docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com

5. Build the Docker Image
Build the image locally from your Dockerfile.

sudo docker build -t lab-repo-<ACCOUNT_ID> .

6. Tag the Docker Image for ECR
Tag the locally built image with the ECR repository URI so you can push it.

sudo docker tag lab-repo-<ACCOUNT_ID>:latest <ACCOUNT_ID>[.dkr.ecr.us-west-2.amazonaws.com/lab-repo-](https://.dkr.ecr.us-west-2.amazonaws.com/lab-repo-)<ACCOUNT_ID>:latest

7. Push the Image to ECR
Push the tagged image to your ECR repository.

sudo docker push <ACCOUNT_ID>[.dkr.ecr.us-west-2.amazonaws.com/lab-repo-](https://.dkr.ecr.us-west-2.amazonaws.com/lab-repo-)<ACCOUNT_ID>:latest
