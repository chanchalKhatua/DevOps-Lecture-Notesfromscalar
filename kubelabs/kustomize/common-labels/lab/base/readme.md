### View the generated resources 
controlplane:~$ ```k kustomize lab/base/```
```
# Warning: 'commonLabels' is deprecated. Please use 'labels' instead. Run 'kustomize edit fix' to update your Kustomization automatically.
apiVersion: v1
kind: Service
metadata:
  labels:
    app: bingo
    owner: alice
    someName: someValue
  name: web-server
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: bingo
    owner: alice
    someName: someValue
status:
  loadBalancer: {}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: bingo
    owner: alice
    someName: someValue
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bingo
      owner: alice
      someName: someValue
  strategy: {}
  template:
    metadata:
      labels:
        app: bingo
        owner: alice
        someName: someValue
    spec:
      containers:
      - image: nginx:1.27
        name: nginx
        resources: {}
status: {}
```

To apply changes, run: ``` k kustomize lab/base/ | k apply -f -```