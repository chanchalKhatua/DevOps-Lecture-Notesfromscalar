```
controlplane:~/lab/base$ k kustomize .
apiVersion: v1
data:
  myFileName.ini: |
    env: Prod
    age: 12
    user: json
    admin: admin
    org: random
kind: ConfigMap
metadata:
  name: app-whatever-5mhg7fb2h9
---
apiVersion: v1
data:
  app.properties: |
    # application.properties
    FOO=Bar
kind: ConfigMap
metadata:
  name: my-application-properties-989k6527gh
---
apiVersion: v1
data:
  tls.crt: TFMwdExTMUNSVWQuLi50Q2c9PQo=
  tls.key: TFMwdExTMUNSVWQuLi4wdExRbz0K
kind: Secret
metadata:
  name: app-tls-ckm46bh6mg
type: kubernetes.io/tls
---
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - command:
    - sh
    - -c
    - env && sleep 3600
    envFrom:
    - configMapRef:
        name: app-whatever-5mhg7fb2h9
    - secretRef:
        name: app-tls-ckm46bh6mg
    image: busybox:1.36
    name: app
controlplane:~/lab/base$ 
```

To apply changes, run: ``` k kustomize lab/base/ | k apply -f -```