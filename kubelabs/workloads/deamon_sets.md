### Example:

Deploy a DaemonSet for FluentD Logging.
Use the given specifications.
* Name: elasticsearch
* Namespace: kube-system
* Image: registry.k8s.io/fluentd-elasticsearch:1.20

Solution: An easy way to create a DaemonSet is to first generate a YAML file for a Deployment with the command kubectl create deployment elasticsearch --image=registry.k8s.io/fluentd-elasticsearch:1.20 -n kube-system --dry-run=client -o yaml > fluentd.yaml. Next, remove the replicas, strategy and status fields from the YAML file using a text editor. Also, change the kind from Deployment to DaemonSet.

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: elasticsearch
  name: elasticsearch
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: elasticsearch
    spec:
      containers:
      - image: registry.k8s.io/fluentd-elasticsearch:1.20
        name: fluentd-elasticsearch
```
