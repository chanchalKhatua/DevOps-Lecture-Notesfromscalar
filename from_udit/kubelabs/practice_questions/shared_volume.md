## Problem statement:
Create a pod named volume-share-devops.


For the first container, use image `debian` with `latest` tag only and remember to mention the tag i.e `debian:latest`, container should be named as `volume-container-devops-1`, and run a `sleep` command for it so that it remains in running state. Volume `volume-share` should be mounted at path `/tmp/beta`.


For the second container, use image `debian` with the `latest` tag only and remember to mention the tag i.e `debian:latest`, container should be named as `volume-container-devops-2`, and again run a `sleep` command for it so that it remains in running state. Volume `volume-share` should be mounted at path `/tmp/cluster`.


Volume name should be `volume-share` of type `emptyDir`.


After creating the pod, exec into the first container i.e `volume-container-devops-1`, and just for testing create a file beta.txt with any content under the mounted path of first container i.e `/tmp/beta`.


The file beta.txt should be present under the mounted path `/tmp/cluster` on the second container `volume-container-devops-2` as well, since they are using a shared volume.

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: volume-share-devops
  name: volume-share-devops
spec:
  restartPolicy: Never
  volumes:
  - name: volume-share
    emptyDir: {}

  containers:
  - image: debian:latest
    name: volume-container-devops-1
    command: ['sh', '-c', 'sleep 3600']
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/news
  - image: debian:latest
    name: volume-container-devops-2
    command: ['sh', '-c', 'sleep 3600']
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/demo

  dnsPolicy: ClusterFirst
status: {}
```