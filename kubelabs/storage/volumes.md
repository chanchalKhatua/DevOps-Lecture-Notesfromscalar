### 1. Configure a volume to store these logs at /var/log/webapp on the host.

Use the spec provided below.
* Name: webapp
* Image Name: kodekloud/event-simulator
* Volume HostPath: /var/log/webapp
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
  containers:
  - image: kodekloud/event-simulator
    name: webapp
    volumeMounts:
    - mountPath: /log
      name: webapp-log
  volumes:
  - name: webapp-log
    # mount /data/foo, but only if that directory already exists
    hostPath:
      path:  /var/log/webapp # directory location on host
      type: Directory # this field is optional
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```
