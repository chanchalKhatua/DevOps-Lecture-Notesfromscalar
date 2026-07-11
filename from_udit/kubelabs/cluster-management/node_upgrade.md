## Upgrade the worker node to the exact version v1.32.0

* Worker Node Upgraded to v1.32.0
* Worker Node Ready


### Solution:
On the node01 node, run the following commands:

If you are on the controlplane node, run ssh node01 to log in to the node01.

Use any text editor you prefer to open the file that defines the Kubernetes apt repository.
```
vim /etc/apt/sources.list.d/kubernetes.list
```
Update the version in the URL to the next available minor release, i.e v1.32.
```
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /
```
After making changes, save the file and exit from your text editor. Proceed with the next instruction.
```
apt update

apt-cache madison kubeadm
```
Based on the version information displayed by apt-cache madison, it indicates that for Kubernetes version 1.32.0, the available package version is 1.32.0-1.1. Therefore, to install kubeadm for Kubernetes v1.32.0, use the following command:
```
apt-get install kubeadm=1.32.0-1.1

# Upgrade the node 
kubeadm upgrade node
```

Now, upgrade the Kubelet version.
```
apt-get install kubelet=1.32.0-1.1
```
Run the following commands to refresh the systemd configuration and apply changes to the Kubelet service:
```
systemctl daemon-reload

systemctl restart kubelet
```
Type exit or logout or enter CTRL + d to go back to the controlplane node.

To bring the node01 into ready state:
```
kubectl uncordon node01
```
