## Sidecar container Example

### Problem statement: 

Create a Pod named `sidecar-application` with two containers using the sidecar pattern.

The primary container must:

Use the `busybox` image.

Periodically write a greeting message along with the current date and time to a file named `app.log` such as : `date followed by "Hi there! Greetings from sidecar-application."`

The file name must not be changed.

The `sidecar` container must:

Use the `nginx` image.

Serve the contents of the same `app.log` file over HTTP.
Both containers must:

Share the same volume.

Ensure that updates written by the primary container are immediately visible when accessing the log file through nginx.

Expose the application using a Kubernetes Service so that the log file can be accessed via HTTP.

### Solution:

pod.yaml:
```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: sidecar-application
  name: sidecar-application
spec:
  volumes:
    - name: data
      emptyDir: {}  
  containers:
  - image: busybox:1.28
    name: application
    volumeMounts:
    - name: data
      mountPath: /var/log/app
    command:
    - sh
    - -c
    - |
      cd /var/log/app
      ln -sf app.log index.html
      while true; do
        echo "$(date): Hi there! Greetings from sidecar-application." >> app.log
        sleep 2
      done
  - image: nginx:latest
    name:  sidecar-container
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

svc.yaml:
```
apiVersion: v1
kind: Service
metadata:
  labels:
    run: sidecar-application
  name: sidecar-application-svc
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: sidecar-application
status:
  loadBalancer: {}
```

Output:
```
controlplane:~$ k get ep sidecar-application-svc 
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                      ENDPOINTS        AGE
sidecar-application-svc   192.168.1.8:80   17m
controlplane:~$ curl http://192.168.1.8:80 | less
controlplane:~$ curl http://192.168.1.8:80 | head -20
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Thu Jan  8 04:46:17 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:19 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:21 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:23 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:25 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:27 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:29 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:31 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:33 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:35 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:37 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:39 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:41 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:43 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:45 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:47 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:49 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:51 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:53 UTC 2026: Hi there! Greetings from sidecar-application.
Thu Jan  8 04:46:55 UTC 2026: Hi there! Greetings from sidecar-application.
100 15276  100 15276    0     0  3004k      0 --:--:-- --:--:-- --:--:-- 3729k
curl: Failed writing body
controlplane:~$ 
```