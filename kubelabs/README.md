# Kubernetes CKA Labs & Study Materials

This repository contains comprehensive study materials, practice questions, and examples for Kubernetes CKA (Certified Kubernetes Administrator) exam preparation.

## 📁 Repository Structure

### 📦 **workloads/** (11 files, 6 YAMLs)
Kubernetes workload resources and pod management
- **Documentation**: Deployments, DaemonSets, StatefulSets, Multi-container pods, Init containers, Pod lifecycle
- **YAML Examples**: 
  - `daemonset-fluentd-example.yaml` - DaemonSet for logging
  - `deployment-with-nodeport-service.yaml` - Complete deployment with service
  - `deployment_with_sidecar.yaml` - Deployment with sidecar pattern
  - `init-container-example.yaml` - Init container pattern
  - `multi-container-pod-example.yaml` - Multiple containers in one pod
  - `sidecar-container-example.yaml` - Sidecar pattern for log processing
  - `shared-volume-example.yaml` - Shared volume between containers

### ⚙️ **scheduling/** (8 files, 3 YAMLs)
Pod scheduling and node management
- **Documentation**: Taints and tolerations, Node affinity, Node maintenance, Static pods, Custom schedulers
- **YAML Examples**:
  - `node-affinity-example.yaml` - Node affinity configuration
  - `toleration-example.yaml` - Pod tolerations
  - `static-pod-example.yaml` - Static pod definition

### 📈 **autoscaling/** (3 files, 1 YAML)
Autoscaling configurations
- **Documentation**: Horizontal Pod Autoscaler (HPA), Vertical Pod Autoscaler (VPA)
- **YAML Examples**: `hpa.yaml` - HPA with custom metrics

### 🌐 **networking/** (4 files, 3 YAMLs)
Networking resources and configurations
- **Documentation**: Ingress controllers and rules, Network policies
- **YAML Examples**:
  - `ingress.yaml` - Ingress configuration
  - `network-policy-example.yaml` - Network policy for pod security
  - `httproute-example.yaml` - HTTPRoute using Gateway API

### 💾 **storage/** (12 files, 5 YAMLs)
Persistent storage management
- **Documentation**: PersistentVolumes (PV), PersistentVolumeClaims (PVC), Volume types
- **YAML Examples**:
  - `complete-pv-pvc-pod-service-example.yaml` - Complete storage setup
  - `pv-pvc-pod-svc-app/` - Complete application example with PV, PVC, Pod, and Service

### 🗄️ **storage-class/**
Dynamic provisioning with StorageClasses
- Storage class configurations
- Volume expansion
- Delayed volume binding

### 🔐 **security/**
Security features and RBAC
- Security contexts
- Secrets management
- RBAC (Roles, ClusterRoles, RoleBindings, ClusterRoleBindings)
- Network policies
- PKI and certificates

### 🛠️ **cluster-management/**
Cluster administration tasks
- Cluster upgrades (kubeadm)
- Node upgrades
- etcd backup and restore
- Admission controllers

### 📝 **mocks/**
Mock exams and troubleshooting scenarios
- `cka-troubleshooting/`: Real exam-style troubleshooting problems
- `udemy-mocks/`: Udemy practice exam questions

### ✍️ **practice-questions/**
Additional practice scenarios organized by topic
- Deployment and service creation
- Application troubleshooting
- Configuration management
- Multi-tier applications (LAMP stack)

### ⌨️ **imperative-commands/**
Quick reference for kubectl imperative commands
- Pod creation shortcuts
- Deployment management
- Service exposure

### 📄 **misc/**
Miscellaneous files and utilities
- Configuration files
- Helper scripts
- Additional resources

### 📒 **textFiles/**
Study notes and documentation
- Date-stamped study notes
- Personal annotations

---

## 🚀 Quick Start

### Useful Commands:

## Imperative Commands:

### 1. Create a service redis-service to expose the redis application within the cluster on port 6379.

```
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml
```

### 2. Create a deployment named webapp using the image kodekloud/webapp-color with 3 replicas.

```
kubectl create deploy webapp --image=kodekloud/webapp-color --replicas=3 
```

### 3. Create a new pod called custom-nginx using the nginx image and run it on container port 8080.

``` 
kubectl run custom-nginx --image=nginx --port=8080
```

### 4. Create a new namespace called dev-ns.

``` 
kubectl create ns dev-ns
```

### 5. Create a new deployment called redis-deploy in the dev-ns namespace with the redis image. It should have 2 replicas.

``` 
kubectl create deploy redis-deploy --image=redis --replicas=2 -n dev-ns
```

### 6. Create a pod called httpd using the image httpd:alpine in the default namespace. Next, create a service of type ClusterIP by the same name (httpd). The target port for the service should be 80.

``` 
kubectl run httpd --image=httpd:alpine 
kubectl expose pod httpd --port=80 --name httpd --type=ClusterIP
```
OR
```
kubectl run httpd --image=httpd:alpine --port=80 --expose
```
