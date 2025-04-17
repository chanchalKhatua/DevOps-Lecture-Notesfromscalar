
# 🚀 Kubernetes (K8s) Overview and Quick Reference

## 🌐 Types of Kubernetes Setups

### 1. Vanilla Kubernetes
- Pure upstream Kubernetes with no custom modifications.
- Installed and managed manually (self-hosted).

### 2. Kubernetes for Developers (Local Development & Testing)

| Tool        | Description                                                                 |
|-------------|-----------------------------------------------------------------------------|
| **kind**    | "Kubernetes IN Docker" – lightweight clusters using Docker containers.      |
| **minikube**| Runs a single-node K8s cluster locally with optional GUI support.           |
| **MicroK8s**| Lightweight snap-based K8s from Canonical (Ubuntu).                         |

### 3. Managed Kubernetes Services

| Platform     | Provider      |
|--------------|---------------|
| **GKE**      | Google Cloud  |
| **EKS**      | AWS           |
| **AKS**      | Azure         |
| **OKE**      | Oracle Cloud  |
| **OpenShift**| Red Hat       |

---

## ⚙️ Kubernetes Context & Kubeconfig

```bash
export KUBECONFIG=/path/to/config1:/path/to/config2
```

### Kubeconfig File Structure
- **clusters**: cluster definitions
- **users**: authentication info
- **contexts**: maps users to clusters
- **current-context**: currently active context

### Key Commands

- 🔍 **View Current Context**
```bash
kubectl config current-context
```

- 📋 **List All Contexts**
```bash
kubectl config get-contexts
```

- 🔄 **Switch Context**
```bash
kubectl config use-context <context-name>
```

- 📍 **Set Default Namespace for Context**
```bash
kubectl config set-context demo-context --namespace=dev
```

---

## 🛠 kind Multi-Node Cluster Example

**multi-node.yaml**
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

**Create Cluster**
```bash
kind create cluster --config=multi-node.yaml --name my-cluster
```

---

## 🐳 Docker vs Kubernetes Commands

| Docker Command                  | Kubernetes Equivalent     |
|--------------------------------|---------------------------|
| `docker ps`                    | `kubectl get pods`        |
| `docker run nginx`             | Use deployment or pod     |
| Image: `nginx`                 | Same in K8s pod spec      |

---

## 🔧 Tools and Concepts Recap

- `kubectl`: CLI to interact with Kubernetes cluster.
- `docker`: Container engine, often used under the hood.
- `kind`, `minikube`, `microk8s`: Local cluster solutions.
- `GKE`, `EKS`, `AKS`, `OKE`: Cloud-managed K8s.
- Kubeconfig: Defines cluster access configuration and contexts.

---

Happy Kube-ing! ☸️
