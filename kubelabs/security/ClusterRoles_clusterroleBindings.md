# Cluster-wide RBAC

**Roles** are used to control access to namespace scoped K8s resources. **ClusterRoles are used to control access to cluster-scoped resources.** Example:

- Providing access to the cluster admin to create or delete nodes in a cluster. ****
- Providing access to the storage admin to create or delete PVs

### Creating a ClusterRole and binding it to a User
The definition file is very similar to that of Role except the kind and the resources.
```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
	name: cluster-admin
rules:
	- apiGroups: [""]
		resources: ["nodes"]
		verbs: ["list", "get", "create", "delete"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
	name: cluster-admin-role-binding
subjects:
	- kind: User
		name: cluster-admin-user
		apiGroup: rbac.authorization.k8s.io
roleRef:
	kind: ClusterRole
	name: cluster-admin
	apiGroup: rbac.authorization.k8s.io

```
### ClusterRole for Namespace-scoped Resources
ClusterRoles and ClusterRoleBindings can also be used to allow users to access namespace scoped resources. This way, the user can access that resource across the cluster in any namespace. 
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
	name: developer
rules:
	- apiGroups: [""]
		resources: ["pods"]
		verbs: ["list", "get", "create", "delete"]
```

Example ClusterRole and ClusterRoleBinding for Storage Admin
```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: storage-admin
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes", "storageclasses"]
    verbs: ["list", "get", "create", "delete"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: arkalim-storage-admin
subjects:
  - kind: User
    name: arkalim
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: storage-admin
  apiGroup: rbac.authorization.k8s.io
```
