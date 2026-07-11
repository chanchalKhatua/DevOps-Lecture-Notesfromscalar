```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: lamp-wp
  name: lamp-wp
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: lamp-wp
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: lamp-wp
    spec:
      containers:
      - env:
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              key: MYSQL_DATABASE
              name: mysql-db
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              key: MYSQL_ROOT_PASSWORD
              name: mysql-root-pwd
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              key: MYSQL_USER
              name: mysql-user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              key: MYSQL_PASSWORD
              name: mysql-pwd
        - name: MYSQL_HOST
          valueFrom:
            secretKeyRef:
              key: MYSQL_HOST
              name: mysql-host
        image: webdevops/php-apache:alpine-3-php7
        imagePullPolicy: IfNotPresent
        name: httpd-php-container
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /opt/docker/etc/php/php.ini
          name: php-config
          subPath: php.ini
      - env:
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              key: MYSQL_DATABASE
              name: mysql-db
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              key: MYSQL_ROOT_PASSWORD
              name: mysql-root-pwd
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              key: MYSQL_USER
              name: mysql-user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              key: MYSQL_PASSWORD
              name: mysql-pwd
        - name: MYSQL_HOST
          valueFrom:
            secretKeyRef:
              key: MYSQL_HOST
              name: mysql-host
        image: mysql:5.6
        imagePullPolicy: IfNotPresent
        name: mysql-container
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - configMap:
          defaultMode: 420
          name: php-config
        name: php-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: php-config
data:
  php.ini: |
    variables_order = "EGPCS"
```


### Secrets:

```
k create secret generic mysql-root-pwd --from-literal=MYSQL_ROOT_PASSWORD=rootpwdsecret
k create secret generic mysql-db --from-literal=MYSQL_DATABASE=mysql
k create secret generic mysql-user --from-literal=MYSQL_USER=mysql
k create secret generic  mysql-pwd --from-literal=MYSQL_PASSWORD=mysqlpwd
k create secret generic mysql-host --from-literal=MYSQL_HOST=mysql_host
```

