## Taints and Tolerations
Tolerations are applied to pods. Tolerations allow the scheduler to schedule pods with matching taints. Tolerations allow scheduling but don't guarantee scheduling: the scheduler also evaluates other parameters as part of its function.

Taints and tolerations work together to ensure that pods are not scheduled onto inappropriate nodes. One or more taints are applied to a node; this marks that the node should not accept any pods that do not tolerate the taints.

### Concepts
You add a taint to a node using kubectl taint. For example,
```
kubectl taint nodes node1 key1=value1:NoSchedule
```
places a taint on node node1. The taint has key key1, value value1, and taint effect NoSchedule. This means that no pod will be able to schedule onto node1 unless it has a matching toleration.

To remove the taint added by the command above, you can run:

```
kubectl taint nodes node1 key1=value1:NoSchedule-
```
You specify a toleration for a pod in the PodSpec. Both of the following tolerations "match" the taint created by the kubectl taint line above, and thus a pod with either toleration would be able to schedule onto node1:

```
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
tolerations:
- key: "key1"
  operator: "Exists"
  effect: "NoSchedule"
```
The default Kubernetes scheduler takes taints and tolerations into account when selecting a node to run a particular Pod. However, if you manually specify the .spec.nodeName for a Pod, that action bypasses the scheduler; the Pod is then bound onto the node where you assigned it, even if there are NoSchedule taints on that node that you selected. If this happens and the node also has a NoExecute taint set, the kubelet will eject the Pod unless there is an appropriate tolerance set.

### Examples
1. Create a taint on node01 with key of spray, value of mortein and effect of NoSchedule
```
kubectl taint nodes node01 spray=mortein:NoSchedule
```
2. Remove the taint on controlplane, which currently has the taint effect of NoSchedule.

Run the command: 
```
kubectl taint nodes controlplane node-role.kubernetes.io/control-plane:NoSchedule- to untaint the node.
```
