# PV, PVC, Pod, and Service Complete Example

This directory contains a complete example of using PersistentVolumes with Pods and Services in Kubernetes.

## Files

- `pv.yaml` - PersistentVolume definition (4Gi storage, hostPath: /mnt/data)
- `pvc.yaml` - PersistentVolumeClaim (requests 3Gi from the PV)
- `pod.yaml` - Pod that uses the PVC and mounts it to nginx html directory
- `svc.yaml` - NodePort Service to expose the pod externally
- `cmd.md` - Useful commands for testing the setup

## Usage

1. Apply resources in order:
```bash
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f pod.yaml
kubectl apply -f svc.yaml
```

2. Verify the setup:
```bash
kubectl get pv,pvc,pod,svc
```

3. Test by writing to the volume (see cmd.md for details)

## Concept

This demonstrates:
- How to create and bind PersistentVolumes
- How pods consume storage via PVCs
- How to expose applications with Services
- Volume mounting in containers
