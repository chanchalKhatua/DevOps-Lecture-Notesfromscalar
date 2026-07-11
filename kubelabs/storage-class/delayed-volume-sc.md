### Create a new Storage Class called delayed-volume-sc that makes use of the below specs:
* provisioner: kubernetes.io/no-provisioner
* volumeBindingMode: WaitForFirstConsumer
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: delayed-volume-sc
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
provisioner:  kubernetes.io/no-provisioner
reclaimPolicy: Retain # default value is Delete
allowVolumeExpansion: true
mountOptions:
  - discard # this might enable UNMAP / TRIM at the block storage layer
volumeBindingMode: WaitForFirstConsumer
parameters:
  guaranteedReadWriteLatency: "true" # provider-specific
```
