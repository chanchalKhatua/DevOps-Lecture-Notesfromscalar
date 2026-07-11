## Upgrade the controlplane components to exact version v1.32.0
Upgrade the kubeadm tool (if not already), then the controlplane components, and finally the kubelet. Practice referring to the Kubernetes documentation page.

* Controlplane Node Upgraded to v1.32.0
* Controlplane Kubelet Upgraded to v1.32.0

### Solution:
#### To seamlessly transition from Kubernetes v1.31 to v1.32 and gain access to the packages specific to the desired Kubernetes minor version, follow these essential steps during the upgrade process. This ensures that your environment is appropriately configured and aligned with the features and improvements introduced in Kubernetes v1.32.

On the controlplane node:

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
```
Run the following command to upgrade the Kubernetes cluster.
```
kubeadm upgrade plan v1.32.0

kubeadm upgrade apply v1.32.0
```
Note that the above steps can take a few minutes to complete.

Now, upgrade the Kubelet version. Also, mark the node (in this case, the "controlplane" node) as schedulable.
```
apt-get install kubelet=1.32.0-1.1
```
Run the following commands to refresh the systemd configuration and apply changes to the Kubelet service:
```
systemctl daemon-reload

systemctl restart kubelet
```
