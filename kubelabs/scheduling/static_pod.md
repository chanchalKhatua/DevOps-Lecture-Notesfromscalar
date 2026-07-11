## About:

Static Pods are managed directly by the kubelet daemon on a specific node, without the API server observing them. Unlike Pods that are managed by the control plane (for example, a Deployment); instead, the kubelet watches each static Pod (and restarts it if it fails).

Static Pods are always bound to one Kubelet on a specific node.

The kubelet automatically tries to create a mirror Pod on the Kubernetes API server for each static Pod. This means that the Pods running on a node are visible on the API server, but cannot be controlled from there. The Pod names will be suffixed with the node hostname with a leading hyphen.

* manifests file stored at: /etc/kubernetes/manifests/

### Example:

Create a static pod named static-busybox that uses the busybox image and the command sleep 1000

To do: Create a pod definition file called static-busybox.yaml with the provided specs and place it under /etc/kubernetes/manifests directory.

Solution:
Create a pod definition file in the manifests folder. To do this, run the command:
kubectl run --restart=Never --image=busybox static-busybox --dry-run=client -o yaml --command -- sleep 1000 > /etc/kubernetes/manifests/static-busybox.yaml

```
apiVersion: v1
kind: Pod
metadata:
  name: static-busybox
  labels:
    role: static-busybox
spec:
  containers:
    - name: static-busybox
      image: busybox
      command: ["sleep"]
      args: ["1000"]
```
