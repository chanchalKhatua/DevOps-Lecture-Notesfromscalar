## Examples:


### Problem statement: The reason the application is failed is because we have not created the secrets yet. Create a new secret named db-secret with the data given below.

You may follow any one of the methods discussed in lecture to create the secret.

* Secret Name: db-secret

* Secret 1: DB_Host=sql01

* Secret 2: DB_User=root

* Secret 3: DB_Password=password123

  ![image](https://github.com/user-attachments/assets/cd4f1887-8807-40ff-b203-7cde3cf05f73)

Solution: 
Run the command: 
```
kubectl create secret generic db-secret --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123
```

### 2. Configure webapp-pod to load environment variables from the newly created secret.
Delete and recreate the pod if required.
* Pod name: webapp-pod
* Image name: kodekloud/simple-webapp-mysql
* Env From: Secret=db-secret

Solution:
```
---
apiVersion: v1 
kind: Pod 
metadata:
  labels:
    name: webapp-pod
  name: webapp-pod
  namespace: default 
spec:
  containers:
  - image: kodekloud/simple-webapp-mysql
    imagePullPolicy: Always
    name: webapp
    envFrom:
    - secretRef:
        name: db-secret
```

## Useful commands:

```
echo -n "password123" | base64

kubectl create secret generic db-secret --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123 

kubectl create secret generic db-secret --from-file=creds

kubectl create secret tls webhook-server-tls -n webhook-demo \
  --cert=/root/keys/webhook-server-tls.crt \
  --key=/root/keys/webhook-server-tls.key
```