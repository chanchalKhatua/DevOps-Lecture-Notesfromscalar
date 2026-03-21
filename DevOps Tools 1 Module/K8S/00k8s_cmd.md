---

# 📘 Kubernetes Commands Cheat Sheet

## 🔹 Cluster & Nodes

```bash
kubectl get nodes
kubectl describe node <node-name>
kubectl get nodes -o wide
```

---

## 🔹 Pods

```bash
kubectl get pods
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- sh
kubectl delete pod <pod-name>
```

---

## 🔹 Create Resources (Quick Way)

```bash
kubectl run pod1 --image=nginx
kubectl create deployment web --image=nginx
kubectl create namespace dev
```

---

## 🔹 Deployments

```bash
kubectl get deployments
kubectl describe deployment <name>
kubectl delete deployment <name>
```

---

## 🔹 Scaling

```bash
kubectl scale deployment <name> --replicas=5
```

---

## 🔹 Rolling Updates & Rollback

```bash
kubectl set image deployment/<name> <container>=<image>
kubectl rollout status deployment <name>
kubectl rollout history deployment <name>
kubectl rollout undo deployment <name>
```

---

## 🔹 ReplicaSet

```bash
kubectl get rs
kubectl describe rs <name>
```

---

## 🔹 DaemonSet

```bash
kubectl get daemonsets
kubectl describe daemonset <name>
```

---

## 🔹 Services

```bash
kubectl get svc
kubectl describe svc <name>
kubectl expose deployment <name> --type=NodePort --port=80
```

---

## 🔹 YAML & Apply

```bash
kubectl apply -f file.yaml
kubectl delete -f file.yaml
kubectl get deployment <name> -o yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml
```

---

## 🔹 Debugging (VERY IMPORTANT)

```bash
kubectl get all
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl get events
```

---

## 🔹 Node Management

```bash
kubectl cordon <node-name>
kubectl uncordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
kubectl label node <node-name> key=value
```

---

## 🔹 Namespace

```bash
kubectl get ns
kubectl create ns dev
kubectl get pods -n dev
kubectl delete ns dev
```

---

## 🔹 Config Help

```bash
kubectl explain pod
kubectl explain deployment.spec
kubectl config view
kubectl config get-contexts
kubectl config use-context <context>
```

---

# 🚀 Pro Tip

Use this daily:

```bash
kubectl get all
kubectl get pods -o wide
kubectl describe pod <pod>
```

👉 This builds **real troubleshooting skill**

---

If you want, I can next give you:

👉 **“Top 30 Kubernetes commands used in real DevOps jobs (not basic ones)”**
