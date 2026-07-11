### Create a new PersistentVolumeClaim by the name of local-pvc that should bind to the volume local-pv.
Inspect the pv local-pv for the specs.

* PVC: local-pvc
* Correct Access Mode?
* Correct StorageClass Used?
* PVC requests volume size = 500Mi?

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```
