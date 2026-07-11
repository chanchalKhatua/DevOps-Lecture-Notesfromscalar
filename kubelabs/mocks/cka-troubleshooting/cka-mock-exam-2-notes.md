# CKA Mock Exam – Personal Study Notes

These notes summarize multiple CKA-style mock exam questions I practiced.
Each section explains:
- What the question was testing.
- How to solve it (step-by-step).
- Key exam traps.
- Commands and patterns to remember.

---

## 1. Static Local Storage (StorageClass, PV, PVC)

### Goal
Create:
- StorageClass with `no-provisioner`.
- Local PersistentVolume with node affinity.
- PVC bound to the specific PV.

### Steps
1. Create StorageClass:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: orange-stc-cka07-str
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

2. Create PersistentVolume:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: orange-pv-cka07-str
spec:
  capacity:
    storage: 150Mi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: orange-stc-cka07-str
  local:
    path: /opt/orange-data-cka07-str
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - cluster1-controlplane
```

3. Create PVC:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: orange-pvc-cka07-str
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: orange-stc-cka07-str
  volumeName: orange-pv-cka07-str
  resources:
    requests:
      storage: 128Mi
```

### Key Notes
- PV comes before PVC.
- Node affinity and local path belong ONLY in PV.
- `WaitForFirstConsumer` means PVC may stay Pending until a Pod exists.

---

## 2. Helm: Install New Version and Remove Old One

### Goal
- Validate a Helm chart.
- Install new version.
- Uninstall old version.

### Steps
1. Check existing releases:
```bash
helm list -n default
```

2. Validate chart:
```bash
cd /root/new-version
helm lint .
```

3. Install new version:
```bash
helm install webpage-server-02 . -n default
```

4. Uninstall old version:
```bash
helm uninstall webpage-server-01 -n default
```

### Key Notes
- `helm lint` is the validation command.
- Follow question wording (install + uninstall vs upgrade).

---

## 3. VPA (Vertical Pod Autoscaler)

### Goal
Deploy a VPA in Auto mode.

### YAML
```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: analytics-vpa
  namespace: cka24456
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: analytics-deployment
  updatePolicy:
    updateMode: Auto
```

### Key Notes
- `Auto` is deprecated but still accepted.
- In exams, follow question text over documentation evolution.
- Verify:
```bash
kubectl get vpa -n cka24456
kubectl describe vpa analytics-vpa -n cka24456
```

---

## 4. ConfigMap Mount Error (not a directory)

### Error
```
not a directory
```

### Root Cause
Mounting a ConfigMap directory onto a file path.

### Fix
Use `subPath`.

```yaml
volumeMounts:
- name: nginx-conf-vol
  mountPath: /etc/nginx/conf.d/default.conf
  subPath: default.conf
```

### Rule
- ConfigMap = directory.
- File mount = `subPath`.

---

## 5. Secrets as Environment Variables

### Create Secret
```bash
kubectl create secret generic db-secret-w105   -n canara-w105   --from-literal=DB_Host=mysql-svc-w105   --from-literal=DB_User=root   --from-literal=DB_Password=password123
```

### Inject into Pod
```yaml
envFrom:
- secretRef:
    name: db-secret-w105
```

### Notes
- Secret and Pod must be in same namespace.
- Keys are case-sensitive.

---

## 6. Gateway API – HTTPS Listener

### Goal
- HTTPS on port 443.
- Hostname `kodekloud.com`.
- TLS secret `kodekloud-tls`.

### Correct Listener
```yaml
listeners:
- name: https
  hostname: kodekloud.com
  port: 443
  protocol: HTTPS
  tls:
    mode: Terminate
    certificateRefs:
    - name: kodekloud-tls
```

### Notes
- HTTPS requires port + protocol + hostname + TLS secret.
- Missing any = fail.

---

## 7. HTTPRoute Path-Based Routing

### Goal
- `/api` → api-service:8080
- `/` → web-service:80

### Rules
```yaml
rules:
- matches:
  - path:
      type: PathPrefix
      value: /api
  backendRefs:
  - name: api-service
    port: 8080

- matches:
  - path:
      type: PathPrefix
      value: /
  backendRefs:
  - name: web-service
    port: 80
```

### Flow of request from Client till the pod(app)
```
Client
  |
  |  NodeIP:31377        (nodePort)
  v
Service (envoy-gateway)
  |
  |  port 80             (Gateway listener)
  v
HTTPRoute
  |
  |  backendRef.port=80  (Service port)
  v
Service (api-service)
  |
  |  targetPort=3000     (Container port)
  v
Pod (API app)

```
### Notes
- More specific path first.
- Default route always last.

---

## 8. Cluster Troubleshooting (kubectl not working)

### Generic Checklist
1. SSH to controlplane.
2. Check kubelet:
```bash
systemctl status kubelet
```
3. Check API server:
```bash
crictl ps | grep kube-apiserver
```
4. Verify certificates and config files:
```bash
ls /etc/kubernetes/manifests
```

---

## How to Survive When You Forget Commands (Very Important)

### 1. Generate YAML Instead of Memorizing
```bash
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml
```

```bash
kubectl explain vpa.spec.updatePolicy
```

### 2. Use kubectl explain (Underrated Superpower)
```bash
kubectl explain gateway.spec.listeners.tls
```

This works OFFLINE and is available in exams.

---

## Helm Without Docs (Reality Check)

- Helm binary is available.
- Internet is NOT.
- Use:
```bash
helm help
helm lint --help
helm install --help
```

### Mental Mapping
- Validation → `helm lint`
- Render only → `helm template`
- Upgrade vs Replace → read question carefully

---

## Final Exam Mindset

- Follow question wording strictly.
- Use kubectl explain when unsure.
- Prefer correctness over elegance.
- Don’t panic if you forget flags — explore with `--help`.

---

_End of notes._
