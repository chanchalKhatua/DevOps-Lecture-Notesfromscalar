# Kubernetes YAML Daily Practice Guide
### From Zero Muscle Memory → Interview Ready

---

## The Core Problem & The Fix

You know the concepts. What fails in interviews is **writing YAML under pressure from scratch**.

The fix is not reading more. The fix is this loop — every single day:

```
Read scenario → Close notes → Write YAML → Apply → Debug → Repeat
```

**Rule 1:** Never start with a blank file. Always scaffold first:
```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deploy.yaml
kubectl create service clusterip my-svc --tcp=80:80 --dry-run=client -o yaml
kubectl create configmap my-cm --from-literal=key=value --dry-run=client -o yaml
kubectl create secret generic my-secret --from-literal=pass=secret123 --dry-run=client -o yaml
kubectl create sa my-sa --dry-run=client -o yaml
kubectl create role my-role --verb=get,list --resource=pods --dry-run=client -o yaml
kubectl create rolebinding my-rb --role=my-role --serviceaccount=default:my-sa --dry-run=client -o yaml
kubectl create cronjob my-cj --image=busybox --schedule="0 * * * *" --dry-run=client -o yaml
```

**Rule 2:** Every K8s YAML has the same 4 top-level sections — memorize this skeleton:
```yaml
apiVersion: <group/version>   # apps/v1, v1, batch/v1, networking.k8s.io/v1
kind: <Kind>                  # Pod, Deployment, Service, etc.
metadata:
  name: <name>
  namespace: <ns>             # omit = default
  labels:
    app: <name>
spec:                         # the "what" — differs per kind
  ...
```

**Rule 3:** Time yourself. Target: write any YAML in under 5 minutes by Week 3.

---

## Time Budget Per Day

| Topic | Time |
|-------|------|
| Kubernetes (YAML + 1 scenario) | **30 min** |
| AWS | 45 min |
| Terraform | 30 min |
| Linux / Networking / Monitoring | 30 min |

30 min K8s is enough **if** you write YAML every day — not read.

### How to split your 30 min K8s block

| Slot | Activity | What to do |
|------|----------|------------|
| **Min 1–10** | Write YAML from scratch | Pick today's concept. No notes. Write the skeleton. Use `--dry-run=client -o yaml` only if stuck. |
| **Min 11–25** | Solve one scenario | Take today's scenario from the weekly plan below. Write full YAML → `kubectl apply` → verify with commands given. |
| **Min 26–30** | Debug one broken object | Introduce a deliberate mistake (wrong label, wrong port, missing restartPolicy). Use `kubectl describe`, `logs`, `get events` to find it. |

> This 3-part loop builds all three interview skills at once: writing speed, scenario thinking, and live debugging.

---
---

# WEEK 1 — Core Building Blocks

---

## Day 1 — Pod

### Interview Scenario
> "Create a Pod running nginx. Add a label `app=web`, set CPU request to 100m and memory request to 128Mi, and pass an environment variable `ENV=production`."

### Your Task (write this without looking)
```
apiVersion: ?
kind: Pod
metadata:
  name: ?
  labels: ?
spec:
  containers:
  - name: ?
    image: ?
    env: ?
    resources: ?
```

### Solution
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: web
spec:
  containers:
  - name: nginx
    image: nginx:latest
    env:
    - name: ENV
      value: production
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "200m"
        memory: "256Mi"
```

### Verify
```bash
kubectl apply -f pod.yaml
kubectl get pod web-pod
kubectl describe pod web-pod
kubectl exec web-pod -- printenv ENV
```

### What interviewers check
- `labels` under `metadata`, not under `spec`
- `env` is a list of `name/value` pairs
- `resources` has both `requests` and `limits`

---

## Day 2 — Deployment

### Interview Scenario
> "Create a Deployment for nginx with 3 replicas. Use rolling update strategy with maxSurge=1 and maxUnavailable=0."

### Solution
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

### Verify
```bash
kubectl apply -f deploy.yaml
kubectl rollout status deployment/nginx-deployment
kubectl get replicasets
# Test rolling update
kubectl set image deployment/nginx-deployment nginx=nginx:1.22
kubectl rollout history deployment/nginx-deployment
# Rollback
kubectl rollout undo deployment/nginx-deployment
```

### What interviewers check
- `selector.matchLabels` must match `template.metadata.labels` EXACTLY
- `strategy.rollingUpdate` is nested under `strategy`
- `containerPort` is informational, not required to open a port

---

## Day 3 — Service

### Interview Scenario
> "Expose your nginx Deployment with a ClusterIP Service on port 80. Then create a NodePort Service on port 30080."

### Solution — ClusterIP
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - port: 80           # Service port (what clients call)
    targetPort: 80     # Container port (what pod listens on)
    protocol: TCP
```

### Solution — NodePort
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080    # Must be 30000-32767
    protocol: TCP
```

### Imperative shortcut (interview speed hack)
```bash
kubectl expose deployment nginx-deployment --port=80 --target-port=80 --type=ClusterIP
kubectl expose deployment nginx-deployment --port=80 --target-port=80 --type=NodePort --name=nginx-np
```

### Verify
```bash
kubectl get svc
kubectl describe svc nginx-clusterip
# Test from inside cluster
kubectl run test --image=busybox --rm -it -- wget -qO- http://nginx-clusterip
```

---

## Day 4 — ConfigMap

### Interview Scenario
> "Create a ConfigMap with `APP_COLOR=blue` and `APP_MODE=prod`. Mount it as (a) environment variables, and (b) a file at `/etc/config`."

### ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_COLOR: blue
  APP_MODE: prod
  config.properties: |
    color=blue
    mode=prod
    version=1.0
```

### Pod using ConfigMap — Method A: envFrom (all keys as env vars)
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-pod-env
spec:
  containers:
  - name: app
    image: nginx
    envFrom:
    - configMapRef:
        name: app-config
```

### Pod using ConfigMap — Method B: specific key as env var
```yaml
spec:
  containers:
  - name: app
    image: nginx
    env:
    - name: COLOR
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: APP_COLOR
```

### Pod using ConfigMap — Method C: volume mount
```yaml
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
```

### Verify
```bash
kubectl exec config-pod-env -- printenv APP_COLOR
kubectl exec config-pod-vol -- ls /etc/config
kubectl exec config-pod-vol -- cat /etc/config/APP_COLOR
```

---

## Day 5 — Secret

### Interview Scenario
> "Create a Secret with `DB_USER=admin` and `DB_PASS=secret123`. Mount it as environment variables in a Pod."

### Create Secret (imperative — fastest)
```bash
kubectl create secret generic db-secret \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASS=secret123
```

### Secret YAML (values must be base64)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  DB_USER: YWRtaW4=        # echo -n "admin" | base64
  DB_PASS: c2VjcmV0MTIz   # echo -n "secret123" | base64
```

### Pod using Secret — as env vars
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: nginx
    envFrom:
    - secretRef:
        name: db-secret
    # OR specific key:
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: DB_PASS
```

### Pod using Secret — as volume (for TLS certs, ssh keys)
```yaml
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: secret-vol
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-vol
    secret:
      secretName: db-secret
```

### Verify
```bash
kubectl get secret db-secret -o jsonpath='{.data.DB_USER}' | base64 -d
kubectl exec secret-pod -- printenv DB_USER
```

---

## Day 6 — Namespace + ResourceQuota

### Interview Scenario
> "Create a namespace `dev-team`. Add a ResourceQuota: max 4 CPUs, 8Gi memory, 10 pods. Deploy nginx into this namespace."

### Namespace
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev-team
  labels:
    env: development
```

### ResourceQuota
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev-team
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "10"
    services: "5"
```

### LimitRange (sets defaults — useful with quota)
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limits
  namespace: dev-team
spec:
  limits:
  - type: Container
    default:
      cpu: "200m"
      memory: "256Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
```

### Deploy into namespace
```bash
kubectl apply -f ns.yaml
kubectl apply -f quota.yaml
kubectl run nginx --image=nginx -n dev-team
kubectl get resourcequota -n dev-team
```

---

## Day 7 — Revision Day

Write all 6 YAMLs from scratch in one go — no notes. Target: under 30 minutes total.

---
---

# WEEK 2 — Workload Patterns

---

## Day 8 — Liveness + Readiness Probes

### Interview Scenario
> "Your app crashes silently without restarting. Add a liveness probe on HTTP /health port 8080. App takes 30 seconds to start — add readiness probe that waits."

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-pod
spec:
  containers:
  - name: app
    image: myapp:1.0
    ports:
    - containerPort: 8080
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 15   # wait before first check
      periodSeconds: 10          # check every 10s
      failureThreshold: 3        # restart after 3 failures
      timeoutSeconds: 5
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 30   # app needs 30s to start
      periodSeconds: 5
      failureThreshold: 3
      successThreshold: 1
    startupProbe:              # NEW: blocks liveness until app is up
      httpGet:
        path: /health
        port: 8080
      failureThreshold: 30     # 30 * 10s = 5 min max startup time
      periodSeconds: 10
```

### Probe types
```yaml
# HTTP probe
httpGet:
  path: /health
  port: 8080
  httpHeaders:
  - name: Authorization
    value: Bearer token123

# TCP probe (databases, non-HTTP services)
tcpSocket:
  port: 3306

# Exec probe (run command inside container)
exec:
  command:
  - /bin/sh
  - -c
  - "redis-cli ping"
```

### Debug probe failures
```bash
kubectl describe pod probe-pod    # look at Events section
kubectl get events --sort-by=.lastTimestamp
```

---

## Day 9 — HPA (Horizontal Pod Autoscaler)

### Interview Scenario
> "Scale your nginx deployment automatically when CPU goes above 70%, minimum 2 pods, maximum 10."

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource                 # BONUS: memory-based too
    resource:
      name: memory
      target:
        type: AverageValue
        averageValue: 200Mi
```

### Imperative shortcut
```bash
kubectl autoscale deployment nginx-deployment --cpu-percent=70 --min=2 --max=10
```

### Verify
```bash
kubectl get hpa
kubectl describe hpa nginx-hpa
# Generate load to trigger scaling
kubectl run load --image=busybox --rm -it -- /bin/sh -c "while true; do wget -q -O- http://nginx-clusterip; done"
```

### Critical: Deployment MUST have resource requests for HPA to work
```yaml
resources:
  requests:
    cpu: "100m"     # Without this, HPA shows <unknown>/70%
```

---

## Day 10 — DaemonSet

### Interview Scenario
> "Deploy a node-exporter DaemonSet on every node. Tolerate all nodes including master/control-plane."

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true             # Access host network
      hostPID: true                 # Access host processes
      tolerations:
      - operator: Exists            # Run on ALL nodes including masters
        effect: NoSchedule
      - operator: Exists
        effect: NoExecute
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
          hostPort: 9100
        securityContext:
          privileged: true
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
```

### Key difference from Deployment
- No `replicas` field — one pod per node automatically
- Use `tolerations` to run on tainted nodes (like master)
- Use `nodeSelector` to run only on specific nodes

---

## Day 11 — Job

### Interview Scenario
> "Run a database backup job. It should run 3 times successfully (not necessarily in parallel). Retry up to 4 times if it fails."

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-backup-job
spec:
  completions: 3           # run 3 times successfully
  parallelism: 1           # one at a time (sequential)
  backoffLimit: 4          # retry 4 times before failing
  activeDeadlineSeconds: 300  # kill if running > 5 min
  ttlSecondsAfterFinished: 100  # clean up after 100s
  template:
    spec:
      restartPolicy: OnFailure   # REQUIRED: Never or OnFailure (not Always)
      containers:
      - name: backup
        image: postgres:14
        command:
        - /bin/sh
        - -c
        - |
          pg_dump -h $DB_HOST -U $DB_USER mydb > /backup/dump.sql
          echo "Backup completed: $(date)"
        env:
        - name: DB_HOST
          value: "postgres-service"
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: DB_USER
        - name: PGPASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: DB_PASS
```

### Critical
```
restartPolicy: OnFailure  ✅
restartPolicy: Always     ❌  (Jobs must use Never or OnFailure)
```

---

## Day 12 — CronJob

### Interview Scenario
> "Run the same backup job every day at midnight. Keep last 3 successful and 1 failed job history."

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: nightly-backup
spec:
  schedule: "0 0 * * *"           # cron: min hour day month weekday
  timeZone: "Asia/Kolkata"        # Kubernetes 1.25+
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  concurrencyPolicy: Forbid        # Don't run if previous still running
  startingDeadlineSeconds: 300     # If missed, allow up to 5 min late
  jobTemplate:
    spec:
      backoffLimit: 2
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: postgres:14
            command:
            - /bin/sh
            - -c
            - "pg_dump -h postgres-svc -U admin mydb > /backup/$(date +%Y%m%d).sql"
```

### Cron Quick Reference
```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── weekday (0-6, Sun=0)
│ │ │ │ │
* * * * *

"0 0 * * *"    = midnight daily
"0 */6 * * *"  = every 6 hours
"0 9 * * 1"    = every Monday at 9am
"*/5 * * * *"  = every 5 minutes
```

### concurrencyPolicy options
- `Allow` — default, multiple jobs can run at once
- `Forbid` — skip new job if old still running
- `Replace` — kill old job, start new one

---

## Day 13 — Init Container

### Interview Scenario
> "Your app needs the database to be ready before it starts. Add an init container that waits until the DB service is reachable."

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-init
spec:
  initContainers:
  - name: wait-for-db
    image: busybox
    command:
    - /bin/sh
    - -c
    - |
      until nslookup postgres-service; do
        echo "Waiting for DB..."
        sleep 2
      done
      echo "DB is ready!"
  - name: run-migrations
    image: myapp:1.0
    command: ["./migrate.sh"]
    env:
    - name: DB_URL
      value: "postgres://postgres-service:5432/mydb"
  containers:
  - name: app
    image: myapp:1.0
    ports:
    - containerPort: 8080
```

### Rules
- Init containers run sequentially, in order
- All init containers must succeed before the main container starts
- If an init container fails, K8s restarts it based on the Pod's `restartPolicy`
- Init containers don't support `livenessProbe` or `readinessProbe`

---

## Day 14 — Multi-Container Pod (Sidecar)

### Interview Scenario
> "Run nginx as the main container. Add a log-shipper sidecar that reads nginx logs from a shared volume and prints them."

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-with-sidecar
spec:
  containers:
  - name: nginx
    image: nginx:latest
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  - name: log-shipper
    image: busybox
    command:
    - /bin/sh
    - -c
    - "tail -f /var/log/nginx/access.log"
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  volumes:
  - name: shared-logs
    emptyDir: {}
```

### Verify
```bash
kubectl logs nginx-with-sidecar -c nginx          # main container logs
kubectl logs nginx-with-sidecar -c log-shipper    # sidecar logs
kubectl exec nginx-with-sidecar -c nginx -- ls /var/log/nginx
```

---
---

# WEEK 3 — Storage & Networking

---

## Day 15 — PersistentVolume + PVC

### Interview Scenario
> "Create a 5Gi PersistentVolume using hostPath. Create a PVC requesting 2Gi. Mount it in a MySQL Pod."

### PersistentVolume (PV) — cluster admin creates this
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce          # RWO: one node read/write
  # - ReadOnlyMany         # ROX: many nodes read-only
  # - ReadWriteMany        # RWX: many nodes read/write
  persistentVolumeReclaimPolicy: Retain   # Retain / Delete / Recycle
  storageClassName: manual
  hostPath:
    path: /data/mysql
```

### PersistentVolumeClaim (PVC) — developer/app creates this
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: manual
```

### Pod using PVC
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mysql-pod
spec:
  containers:
  - name: mysql
    image: mysql:8
    env:
    - name: MYSQL_ROOT_PASSWORD
      value: rootpass
    volumeMounts:
    - name: mysql-data
      mountPath: /var/lib/mysql
  volumes:
  - name: mysql-data
    persistentVolumeClaim:
      claimName: mysql-pvc     # references the PVC
```

### Verify
```bash
kubectl get pv
kubectl get pvc
kubectl describe pvc mysql-pvc   # check Bound status
kubectl get pv mysql-pv          # check CLAIM field
```

---

## Day 16 — StatefulSet

### Interview Scenario
> "Deploy PostgreSQL as a StatefulSet with 3 replicas. Each replica needs its own 1Gi persistent storage."

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: "postgres-headless"    # REQUIRED: must match headless service name
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:14
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: pg-secret
              key: password
        volumeMounts:
        - name: pg-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:               # creates PVC per pod automatically
  - metadata:
      name: pg-data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: standard
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None           # Headless — no load balancing
  selector:
    app: postgres
  ports:
  - port: 5432
```

### StatefulSet Pod DNS pattern
```
postgres-0.postgres-headless.default.svc.cluster.local
postgres-1.postgres-headless.default.svc.cluster.local
postgres-2.postgres-headless.default.svc.cluster.local
```

---

## Day 17 — Ingress

### Interview Scenario
> "Route /api to backend-service:8080 and /web to frontend-service:80. Add TLS using a secret."

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapp.example.com
    secretName: tls-secret      # must contain tls.crt and tls.key
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
```

### TLS Secret
```bash
kubectl create secret tls tls-secret \
  --cert=tls.crt \
  --key=tls.key
```

### pathType options
- `Prefix` — matches /api and /api/users/1
- `Exact` — matches only /api exactly
- `ImplementationSpecific` — up to ingress controller

---

## Day 18 — NetworkPolicy

### Interview Scenario
> "Allow frontend pods to call backend pods on port 8080. Block all other traffic to backend."

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-allow-frontend
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend         # Policy applies TO backend pods
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend    # Allow FROM frontend pods
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database    # Backend can call database
    ports:
    - protocol: TCP
      port: 5432
  - to:                    # Allow DNS (CRITICAL — don't forget this)
    ports:
    - protocol: UDP
      port: 53
```

### Deny ALL ingress (start lockdown)
```yaml
spec:
  podSelector: {}     # applies to all pods
  policyTypes:
  - Ingress
  # no ingress rules = deny all
```

### Common mistake
Forgetting to allow DNS (port 53 UDP) in egress rules breaks name resolution.

---

## Day 19 — NodeSelector + Node Affinity

### Interview Scenario
> "Deploy a high-performance app ONLY on nodes labeled `disktype=ssd`. Then use affinity to prefer gpu nodes but allow others."

### NodeSelector (simple, hard rule)
```yaml
spec:
  nodeSelector:
    disktype: ssd
    kubernetes.io/arch: amd64
```

### Node Affinity (flexible, soft/hard rules)
```yaml
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:   # HARD rule
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values: [ssd, nvme]
      preferredDuringSchedulingIgnoredDuringExecution:  # SOFT rule (try, but ok if not)
      - weight: 80
        preference:
          matchExpressions:
          - key: gpu
            operator: In
            values: ["true"]
      - weight: 20
        preference:
          matchExpressions:
          - key: zone
            operator: In
            values: [us-east-1a]
```

### Label a node
```bash
kubectl label node node1 disktype=ssd
kubectl label node node1 gpu=true
kubectl get nodes --show-labels
```

---

## Day 20 — Taints & Tolerations

### Interview Scenario
> "Dedicate a node for monitoring. Taint it so only monitoring pods run on it."

### Taint the node
```bash
kubectl taint node node1 dedicated=monitoring:NoSchedule
# Effects: NoSchedule | PreferNoSchedule | NoExecute
```

### Toleration in Pod (allows pod to be scheduled on tainted node)
```yaml
spec:
  tolerations:
  - key: dedicated
    operator: Equal
    value: monitoring
    effect: NoSchedule
  nodeSelector:               # also add this to FORCE it to that node
    dedicated: monitoring
```

### Tolerate ALL taints (DaemonSet use case)
```yaml
tolerations:
- operator: Exists     # matches any key/value/effect
```

### Remove a taint
```bash
kubectl taint node node1 dedicated=monitoring:NoSchedule-   # note the dash at end
```

---

## Day 21 — Revision Day

Write from scratch: PV+PVC, StatefulSet, Ingress, NetworkPolicy, NodeAffinity, Taint+Toleration.

---
---

# WEEK 4 — Security + Advanced

---

## Day 22 — RBAC

### Interview Scenario
> "Create a ServiceAccount `ci-bot` in namespace `staging`. Give it read-only access to pods and deployments in that namespace only."

```yaml
# 1. ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ci-bot
  namespace: staging
---
# 2. Role (namespace-scoped)
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: staging
rules:
- apiGroups: [""]              # "" = core API (pods, services, configmaps)
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]          # apps group for deployments
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]
---
# 3. RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ci-bot-binding
  namespace: staging
subjects:
- kind: ServiceAccount
  name: ci-bot
  namespace: staging
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### ClusterRole + ClusterRoleBinding (cluster-wide access)
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-reader-binding
subjects:
- kind: User
  name: john@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-reader
  apiGroup: rbac.authorization.k8s.io
```

### Verify RBAC
```bash
kubectl auth can-i list pods --as=system:serviceaccount:staging:ci-bot -n staging
kubectl auth can-i delete pods --as=system:serviceaccount:staging:ci-bot -n staging
```

### apiGroups cheat sheet
```
""           → core: pods, services, configmaps, secrets, pv, pvc
"apps"       → deployments, statefulsets, daemonsets, replicasets
"batch"      → jobs, cronjobs
"autoscaling"→ hpa
"networking.k8s.io" → ingress, networkpolicy
"rbac.authorization.k8s.io" → roles, rolebindings
```

---

## Day 23 — SecurityContext

### Interview Scenario
> "Harden a pod: run as user 1000, read-only filesystem, drop all capabilities except NET_BIND_SERVICE."

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsUser: 1000             # Pod level
    runAsGroup: 3000
    fsGroup: 2000               # volume mounts group
    runAsNonRoot: true          # reject if image uses root
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    image: nginx:latest
    securityContext:
      runAsUser: 1000           # Container level (overrides pod level)
      runAsNonRoot: true
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
        add: ["NET_BIND_SERVICE"]
    volumeMounts:
    - name: tmp
      mountPath: /tmp           # readOnlyRootFilesystem needs writable tmp
    - name: cache
      mountPath: /var/cache/nginx
    - name: run
      mountPath: /var/run
  volumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}
  - name: run
    emptyDir: {}
```

### Verify
```bash
kubectl exec secure-pod -- id
kubectl exec secure-pod -- cat /proc/1/status | grep Cap
```

---

## Day 24 — Full Application Stack

### Interview Scenario (Advanced — 20-min lab)
> "Deploy a complete application: frontend (nginx), backend (python app), MySQL DB. Use ConfigMap for config, Secret for DB password, Ingress to route traffic."

```yaml
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: myapp
---
# Secret
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  namespace: myapp
type: Opaque
data:
  MYSQL_ROOT_PASSWORD: cm9vdHBhc3M=
  MYSQL_PASSWORD: YXBwcGFzcw==
---
# ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: myapp
data:
  DB_HOST: mysql-service
  DB_PORT: "3306"
  DB_NAME: myapp
---
# MySQL StatefulSet
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: myapp
spec:
  serviceName: mysql-service
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: db-secret
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 5Gi
---
# MySQL Service (headless)
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: myapp
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
---
# Backend Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: myapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: myapp-backend:1.0
        ports:
        - containerPort: 8080
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: db-secret
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
---
# Backend Service
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: myapp
spec:
  selector:
    app: backend
  ports:
  - port: 8080
---
# Frontend Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: myapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: myapp
spec:
  selector:
    app: frontend
  ports:
  - port: 80
---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: myapp
spec:
  ingressClassName: nginx
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
```

---
---

# Top 20 Interview YAML Questions

These are the most commonly asked scenarios — write each from scratch.

| # | Scenario | Key YAML Fields to Know |
|---|----------|------------------------|
| 1 | Pod with resource limits | `resources.requests`, `resources.limits` |
| 2 | Deployment rolling update | `strategy.rollingUpdate.maxSurge/maxUnavailable` |
| 3 | NodePort service on port 30080 | `nodePort: 30080` (must be 30000-32767) |
| 4 | ConfigMap as env + volume | `envFrom.configMapRef`, `volumes.configMap` |
| 5 | Secret base64 value | `data` (base64) vs `stringData` (plain text) |
| 6 | Liveness probe HTTP | `livenessProbe.httpGet.path/port` |
| 7 | Readiness probe with delay | `readinessProbe.initialDelaySeconds` |
| 8 | HPA with CPU 70% | `metrics.resource.target.averageUtilization` |
| 9 | DaemonSet on all nodes | No `replicas`, use `tolerations: [{operator: Exists}]` |
| 10 | CronJob every midnight | `schedule: "0 0 * * *"`, `concurrencyPolicy` |
| 11 | Job with completions | `completions: 3`, `restartPolicy: OnFailure` |
| 12 | StatefulSet with volumeClaimTemplates | `volumeClaimTemplates` + `serviceName` |
| 13 | Ingress path routing | `rules.host.http.paths.backend.service` |
| 14 | NetworkPolicy frontend→backend | `podSelector`, `ingress.from.podSelector` |
| 15 | RBAC read-only pods | `Role + RoleBinding + ServiceAccount` |
| 16 | SecurityContext non-root | `runAsNonRoot: true`, `readOnlyRootFilesystem: true` |
| 17 | Node affinity SSD | `nodeAffinity.requiredDuringScheduling` |
| 18 | Taint + Toleration | `kubectl taint` + `tolerations` in spec |
| 19 | Init container wait for DB | `initContainers` runs before `containers` |
| 20 | Sidecar with shared volume | Two containers + `emptyDir` volume |

---

# Debug Checklist (Interviewers LOVE this)

```bash
# Pod not starting?
kubectl describe pod <name>       # Events section — ImagePullBackOff, CrashLoopBackOff
kubectl logs <pod> [-c container] # App logs
kubectl logs <pod> --previous     # Logs from crashed container

# Pod in Pending?
kubectl describe pod <name>       # Events: Insufficient CPU? No nodes match?
kubectl get events -n <ns>        # Cluster-wide events

# Service not routing?
kubectl get endpoints <svc>       # If empty, selector doesn't match pod labels
kubectl run debug --image=busybox --rm -it -- wget -qO- http://<svc>:<port>

# RBAC denied?
kubectl auth can-i <verb> <resource> --as=<user/sa> -n <ns>

# PVC Pending?
kubectl describe pvc <name>       # No matching PV? StorageClass not found?

# HPA showing unknown?
kubectl describe hpa               # Usually: no resource requests on deployment
```

---

# The 5-Minute YAML Structure Test

Before every practice session, write this from memory in under 5 minutes:

```
1. Pod with label + env + resources
2. Deployment 3 replicas
3. ClusterIP service
4. ConfigMap envFrom
5. Secret volume mount
```

If you can do all 5 in under 5 minutes without errors — you're interview ready.

---

*Total coverage: 24 days × 30 minutes = 12 hours of focused YAML practice*
*After this: you will write any K8s YAML in an interview without hesitation.*
