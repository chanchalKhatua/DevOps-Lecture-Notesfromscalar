
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
Here are **30 high-value, real-world Kubernetes commands** used by DevOps engineers in production. These go beyond basics and focus on **debugging, rollout control, scheduling, and cluster operations** in Kubernetes.

---

# 🚀 Top 30 Kubernetes Commands (DevOps Level)

## 🔴 1–5: Deep Debugging (Most Important)

```bash id="z6ny1c"
kubectl describe pod <pod>
kubectl logs <pod> --previous
kubectl logs -f <pod>
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl exec -it <pod> -- /bin/sh
```

👉 Used for: CrashLoopBackOff, debugging live containers

---

## 🟠 6–10: Advanced Pod Inspection

```bash id="3q2d47"
kubectl get pods -o wide
kubectl get pods -o json
kubectl get pod <pod> -o yaml
kubectl top pod
kubectl top node
```

👉 Requires metrics-server for `top`

---

## 🟡 11–15: Deployment & Rollout Control

```bash id="n8kmq0"
kubectl rollout status deployment <name>
kubectl rollout history deployment <name>
kubectl rollout undo deployment <name>
kubectl rollout restart deployment <name>
kubectl set image deployment/<name> <container>=<image>
```

👉 Used in CI/CD pipelines

---

## 🟢 16–20: Resource Editing & Live Changes

```bash id="m06e2m"
kubectl edit deployment <name>
kubectl patch deployment <name> -p '{"spec":{"replicas":3}}'
kubectl apply -f file.yaml
kubectl apply -k .
kubectl replace -f file.yaml
```

👉 `patch` is heavily used in automation scripts

---

## 🔵 21–25: Node & Scheduling Control

```bash id="1ohoc0"
kubectl cordon <node>
kubectl uncordon <node>
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
kubectl label node <node> key=value
kubectl taint nodes <node> key=value:NoSchedule
```

👉 Used during maintenance & workload isolation

---

## 🟣 26–30: Cluster & Context Management

```bash id="tacplc"
kubectl config get-contexts
kubectl config use-context <context>
kubectl cluster-info
kubectl api-resources
kubectl api-versions
```

👉 Useful when working with multiple clusters (K3s, EKS, etc.)

---

# 💡 Bonus (Highly Used in Real Work)

### 🔥 Port Forward (Debugging service locally)

```bash id="v2nww2"
kubectl port-forward pod/<pod> 8080:80
```

---

### 🔥 Copy files from/to pod

```bash id="xgq3dz"
kubectl cp <pod>:/path/file ./file
kubectl cp ./file <pod>:/path/file
```

---

### 🔥 Run temporary debug pod

```bash id="0qztcy"
kubectl run debug --image=busybox -it --rm -- sh
```

---

# 🧠 How DevOps Engineers Actually Use These

Real workflow:

```bash id="7tdcd6"
kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>
kubectl exec -it <pod> -- sh
```

👉 This sequence solves **80% of production issues**

---

# 🎯 What You Should Do Now

Don’t memorize.

👉 Practice like this:

1. Break deployment (wrong image)
2. Use:

   * `describe`
   * `logs`
   * `events`
3. Fix it
4. Rollout restart

---

# ⚡ Real Interview Tip

If you confidently use these:

* `rollout`
* `logs --previous`
* `exec`
* `cordon/drain`

👉 You are already **above average DevOps candidates**

---

If you want next step:

👉 I can give you a **real production debugging scenario (company-level incident)** and make you solve it step-by-step.


---
Here is your **single consolidated Markdown file** with all advanced DevOps-level Kubernetes commands:

---

# 📘 Kubernetes DevOps Command Cheat Sheet (Top 30 + Bonus)

## 🔴 Debugging (Most Critical)

```bash
kubectl describe pod <pod>
kubectl logs <pod> --previous
kubectl logs -f <pod>
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl exec -it <pod> -- /bin/sh
```

---

## 🟠 Advanced Pod Inspection

```bash
kubectl get pods -o wide
kubectl get pods -o json
kubectl get pod <pod> -o yaml
kubectl top pod
kubectl top node
```

---

## 🟡 Deployment & Rollout Control

```bash
kubectl rollout status deployment <name>
kubectl rollout history deployment <name>
kubectl rollout undo deployment <name>
kubectl rollout restart deployment <name>
kubectl set image deployment/<name> <container>=<image>
```

---

## 🟢 Resource Editing & Changes

```bash
kubectl edit deployment <name>
kubectl patch deployment <name> -p '{"spec":{"replicas":3}}'
kubectl apply -f file.yaml
kubectl apply -k .
kubectl replace -f file.yaml
```

---

## 🔵 Node & Scheduling Control

```bash
kubectl cordon <node>
kubectl uncordon <node>
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
kubectl label node <node> key=value
kubectl taint nodes <node> key=value:NoSchedule
```

---

## 🟣 Cluster & Context Management

```bash
kubectl config get-contexts
kubectl config use-context <context>
kubectl cluster-info
kubectl api-resources
kubectl api-versions
```

---

## ⚡ Bonus (Real DevOps Usage)

```bash
kubectl port-forward pod/<pod> 8080:80
kubectl cp <pod>:/path/file ./file
kubectl cp ./file <pod>:/path/file
kubectl run debug --image=busybox -it --rm -- sh
```

---

# 🚀 Usage Tip

```bash
kubectl get pods
kubectl describe pod <pod>
kubectl logs <pod>
kubectl exec -it <pod> -- sh
```

👉 This flow solves most real production issues.

---

If you want, next I can give you:

👉 **Real Kubernetes production incident scenarios (like company outages) to practice debugging**
I've updated your "Kubernetes DevOps Command Cheat Sheet" note! The missing commands for Networking, Storage, Security, Power User Filtering, and Jobs are now appended to the end of the note so you have the entire list in one place.
http://googleusercontent.com/action_card_content/3
