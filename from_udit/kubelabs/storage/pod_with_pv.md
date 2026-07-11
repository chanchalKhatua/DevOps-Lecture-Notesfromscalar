### Update the webapp pod to use the persistent volume claim as its storage.
Replace hostPath configured earlier with the newly created PersistentVolumeClaim.

* Name: webapp
* Image Name: kodekloud/event-simulator
* Volume: PersistentVolumeClaim=claim-log-1
* Volume Mount: /log

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: webapp
  name: webapp
spec:
  volumes:
    - name: claim-log-1
      persistentVolumeClaim:
        claimName: claim-log-1
  containers:
      - image: kodekloud/event-simulator
        name: webapp
        volumeMounts:
          - mountPath: "/log"
            name: claim-log-1
```
