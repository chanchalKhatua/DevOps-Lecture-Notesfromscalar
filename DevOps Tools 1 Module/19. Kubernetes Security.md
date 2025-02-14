# Kubernetes Security Lecture Notes

---



## **1. StatefulSets and Deployment**


### **1.1 What are StatefulSets?**
StatefulSets manage stateful applications where each pod requires a unique identity and dedicated storage. Unlike Deployments, StatefulSets maintain stable network identities and persistent storage for pods.

### **1.2 Key Features of StatefulSets:**
- **Unique Pod Identifiers:** Each pod created by a StatefulSet gets a unique identifier (e.g., pod-0, pod-1, pod-2).
- **Persistent Storage:** StatefulSets use Persistent Volumes (PVs) to ensure each pod retains its data, even after restarts.
- **Ordered Deployment and Scaling:** Pods are started, scaled, and terminated in a defined order.

### **1.3 What are Deployments?**
Deployments manage stateless applications where all pods are identical and interchangeable. They ensure high availability and easy scaling by treating pods as identical replicas.

### **1.4 Differences Between StatefulSets and Deployments:**
| Feature               | StatefulSets                  | Deployments             |
|-----------------------|--------------------------------|-------------------------|
| **Pod Identity**      | Unique for each pod           | Identical for all pods  |
| **Storage**           | Dedicated Persistent Volumes   | Shared storage (if any) |
| **Startup Sequence**  | Sequential                    | Parallel                |
| **Use Case**          | Databases, Stateful Apps       | Web Servers, APIs       |

### **1.5 Use Cases:**
- **StatefulSets:**
  - Suitable for databases, distributed systems, or applications that require stable storage and unique pod identities.
  - Example: A Cassandra database where each node has a specific role.
- **Deployments:**
  - Ideal for stateless applications like web servers or APIs where any pod can handle requests.
  - Example: A frontend web application with multiple identical instances.

### **1.6 Example YAML Configuration:**
**StatefulSet Example:**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "web"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.17
        ports:
        - containerPort: 80
```

---



## **2. Kubernetes Security and RBAC**


### **2.1 Authentication:**
Authentication verifies the identity of users and components interacting with the Kubernetes API server.

**Methods:**
- Client Certificates
- Service Account Tokens
- External Identity Providers (e.g., AWS, GCP, Azure)
- OpenID Connect (OIDC)

### **2.2 Authorization:**
Authorization determines what actions an authenticated user can perform.

**Mechanisms:**
- Role-Based Access Control (RBAC)
  - Namespace-Level: Roles and RoleBindings
  - Cluster-Level: ClusterRoles and ClusterRoleBindings

### **2.3 RBAC Key Concepts:**
| Concept          | Description                                             |
|------------------|---------------------------------------------------------|
| **Role**         | Grants access to resources within a namespace           |
| **ClusterRole**  | Grants access to resources cluster-wide                 |
| **RoleBinding**  | Binds a Role to users, groups, or service accounts      |
| **ClusterRoleBinding** | Binds a ClusterRole to users, groups, or service accounts cluster-wide |

### **2.4 RBAC Syntax Examples:**
**Role Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

**RoleBinding Example:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane-doe
  apiGroup: ""
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### **2.5 Best Practices:**
- Follow the principle of least privilege to minimize risks.
- Regularly review and audit RBAC policies.
- Use namespace isolation to restrict access boundaries.

---

## **3. Summary Commands**


### **3.1 Authentication and Authorization Commands:**
- `kubectl get pods` - List all pods in a namespace.
- `kubectl delete pods <pod-name>` - Delete a specific pod.
- `kubectl describe roles` - Describe defined RBAC roles within a namespace.

---

