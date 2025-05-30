
# AWS CLI Commands Reference

> Use `aws configure` to set up your CLI credentials before running these commands.

---

## ✅ S3 (Simple Storage Service)

### Create a bucket
```bash
aws s3 mb s3://my-new-bucket-name
```

### List buckets
```bash
aws s3 ls
```

### Upload a file
```bash
aws s3 cp myfile.txt s3://my-new-bucket-name/
```

### Download a file
```bash
aws s3 cp s3://my-new-bucket-name/myfile.txt .
```

### Delete a bucket
```bash
aws s3 rb s3://my-new-bucket-name --force
```

---

## ✅ EC2 (Elastic Compute Cloud)

### List all instances
```bash
aws ec2 describe-instances
```

### Start an instance
```bash
aws ec2 start-instances --instance-ids i-0abcdef1234567890
```

### Stop an instance
```bash
aws ec2 stop-instances --instance-ids i-0abcdef1234567890
```

### Launch a new instance
```bash
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --count 1 \
  --instance-type t2.micro \
  --key-name my-key \
  --security-groups my-sg
```

---

## ✅ IAM (Identity and Access Management)
### You can get your AWS **account number** using the following AWS CLI command:

```bash
aws sts get-caller-identity --query Account --output text
```

### 📌 Output

It will return just your **12-digit account ID**, like:

```
123456789012
```

If you want full identity details (including the ARN and User ID), run:

```bash
aws sts get-caller-identity
```
### List users
```bash
aws iam list-users
```
### Create a User group in AWS with the name test
```bash
aws iam create-group --group-name test
```
### Create a user
```bash
aws iam create-user --user-name devops-user
```


1. Create the policy `AWSPolicy`
2. Create the IAM role `AWSRole` for EC2
3. Attach the policy to the role

---

## 🪄 **Step-by-Step AWS CLI Commands**

### ✅ 1. Create the IAM Policy

Save the following policy JSON as a file named `aws_policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::*"
    },
    {
      "Sid": "Stmt2",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::*/*"
    }
  ]
}
```

Then run:

```bash
aws iam create-policy \
  --policy-name AWSPolicy \
  --policy-document file://aws_policy.json
```
## If we want attach policy to user
### Attach policy to user
```bash
aws iam attach-user-policy \
  --user-name devops-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```
---

### ✅ 2. Create the Trust Policy for EC2

Save this trust policy as `ec2-trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```



```bash
aws iam create-role \
  --role-name AWSRole \
  --assume-role-policy-document file://ec2-trust-policy.json
```

---

### ✅ 3. Attach the Policy to the Role

Assuming the ARN you got in step 1 was something like:

```
arn:aws:iam::<your-account-id>:policy/AWSPolicy
```

Run:

```bash
aws iam attach-role-policy \
  --role-name AWSRole \
  --policy-arn arn:aws:iam::<your-account-id>:policy/AWSPolicy
```

(Replace `<your-account-id>` with your actual AWS account ID)

---

## 🔄 Final Check

To confirm everything was created correctly:

```bash
aws iam list-roles | grep AWSRole
aws iam list-policies | grep AWSPolicy
```

---

## ✅ CloudWatch

### List log groups
```bash
aws logs describe-log-groups
```

### Get recent logs
```bash
aws logs get-log-events \
  --log-group-name "/aws/lambda/my-function" \
  --log-stream-name "2025/05/07/[$LATEST]abcdef123456" \
  --limit 20
```

---

## ✅ Lambda

### List functions
```bash
aws lambda list-functions
```

### Invoke a function
```bash
aws lambda invoke \
  --function-name my-function \
  --payload '{}' \
  response.json
```

---

## ✅ CloudFormation

### Deploy a stack
```bash
aws cloudformation deploy \
  --template-file template.yaml \
  --stack-name my-stack \
  --capabilities CAPABILITY_NAMED_IAM
```

---

## ✅ ECR (Elastic Container Registry)

### Authenticate Docker to ECR
```bash
aws ecr get-login-password | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<region>.amazonaws.com
```

### List repositories
```bash
aws ecr describe-repositories
```

### Push Docker image
```bash
# Tag image
docker tag my-app:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-app:latest

# Push image
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/my-app:latest
```

---

## ✅ General

### Check current identity
```bash
aws sts get-caller-identity
```

### List regions
```bash
aws ec2 describe-regions --all-regions
```

---

## Tips

- Add `--output table` or `--output json` for better formatting.
- Use `--region <region>` to override default region.
