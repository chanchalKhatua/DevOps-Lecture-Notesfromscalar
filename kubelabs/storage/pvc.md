### Let us claim some of that storage for our application. Create a Persistent Volume Claim with the given specification.

* Persistent Volume Claim: claim-log-1
* Storage Request: 50Mi
* Access Modes: ReadWriteOnce

```
cat pvc-claim-log-1 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-log-1
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Mi
```
