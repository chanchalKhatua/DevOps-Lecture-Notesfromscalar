## Example:

### Problem statement:

#### 1. We need to take node01 out for maintenance. Empty the node of all applications and mark it unschedulable.

* Node node01 Unschedulable
* Pods evicted from node01

Solution:
```
kubectl cordon node01
kubectl drain --ignore-daemonsets node01
```
Console output: 
```
controlplane ~ ➜  kubectl cordon node01
node/node01 cordoned

controlplane ~ ➜  kubectl drain --ignore-daemonsets node01
node/node01 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-2g48k, kube-system/kube-proxy-cqvt8
evicting pod default/blue-69968556cc-kl9gl
evicting pod default/blue-69968556cc-jt5kr
pod/blue-69968556cc-kl9gl evicted
pod/blue-69968556cc-jt5kr evicted
node/node01 drained
```
#### 2. The maintenance tasks have been completed. Configure the node node01 to be schedulable again.
Node01 is Schedulable

Solution:
```
kubectl uncordon node01
```

Console output:
```
controlplane ~ ➜  kubectl uncordon node01
node/node01 uncordoned

controlplane ~ ➜  kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   14m   v1.32.0
node01         Ready    <none>          13m   v1.32.0
```

### Useful commands:
```
kubectl describe nodes node01 -o \
  jsonpath='{.items[*].metadata.labels.version}'

kubectl label node node01 color=blue

kubectl get node node01 -o json | jq '.spec.taints'

kubectl get node controlplane -o json | jq '.spec.taints'
```