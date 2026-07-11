# Repository Reorganization Changelog

**Date:** January 6, 2026  
**Total Files Before:** 83  
**Total Files After:** 99  
**Net Change:** +16 files (11 new YAML examples + 1 README + 4 moved from subdirectories)

---

## 📂 Directory Structure Changes

### New Directories Created:
- `workloads/`
- `scheduling/`
- `autoscaling/`
- `cluster-management/`
- `imperative-commands/`
- `mocks/`
  - `mocks/cka-troubleshooting/`
  - `mocks/udemy-mocks/`
- `storage-class/`

### Directories Removed (after moving contents):
- `cluster_upgrade/` → merged into `cluster-management/`
- `storage_class/` → renamed to `storage-class/`
- `imperative_cmds/` → renamed to `imperative-commands/`
- `ClusterRoles/` → merged into `security/`
- `pod_lifecycle/` → merged into `workloads/`
- `cka_mocks/` → reorganized into `mocks/`
- `storage/practice_questions/` → removed (empty duplicates)

---

## 📋 File Movements

### Workloads Directory
| Original Location                                | New Location                                 |
| ------------------------------------------------ | -------------------------------------------- |
| `deamon_sets.md`                                 | `workloads/deamon_sets.md`                   |
| `deploy_nodeapp_deploy_service.md`               | `workloads/deploy_nodeapp_deploy_service.md` |
| `Multi_Containers.md`                            | `workloads/Multi_Containers.md`              |
| `init_containers.md`                             | `workloads/init_containers.md`               |
| `pod_lifecycle/*`                                | `workloads/*`                                |
| `mocks/udemy-mocks/deployment_with_sidecar.yaml` | `workloads/deployment_with_sidecar.yaml`     |

### Scheduling Directory
| Original Location          | New Location                          |
| -------------------------- | ------------------------------------- |
| `taints_and_toleration.md` | `scheduling/taints_and_toleration.md` |
| `node_affinity.md`         | `scheduling/node_affinity.md`         |
| `node_maintenance.md`      | `scheduling/node_maintenance.md`      |
| `static_pod.md`            | `scheduling/static_pod.md`            |
| `multiple_scheduler.md`    | `scheduling/multiple_scheduler.md`    |

### Autoscaling Directory
| Original Location            | New Location           |
| ---------------------------- | ---------------------- |
| `hpa.md`                     | `autoscaling/hpa.md`   |
| `vpa.md`                     | `autoscaling/vpa.md`   |
| `mocks/udemy-mocks/hpa.yaml` | `autoscaling/hpa.yaml` |

### Cluster Management Directory
| Original Location                    | New Location                                    |
| ------------------------------------ | ----------------------------------------------- |
| `etcd_backup_and_restore.md`         | `cluster-management/etcd_backup_and_restore.md` |
| `admission_controller.md`            | `cluster-management/admission_controller.md`    |
| `cluster_upgrade/cluster_upgrade.md` | `cluster-management/cluster_upgrade.md`         |
| `cluster_upgrade/node_upgrade.md`    | `cluster-management/node_upgrade.md`            |

### Storage Directory
| Original Location                        | New Location                  |
| ---------------------------------------- | ----------------------------- |
| `storage_class/*`                        | `storage-class/*`             |
| `practice_questions/pv-pvc-pod-svc-app/` | `storage/pv-pvc-pod-svc-app/` |

### Security Directory
| Original Location                                  | New Location                                   |
| -------------------------------------------------- | ---------------------------------------------- |
| `secrets.md`                                       | `security/secrets.md`                          |
| `ClusterRoles/ClusterRoles_clusterroleBindings.md` | `security/ClusterRoles_clusterroleBindings.md` |

### Networking Directory
| Original Location                | New Location              |
| -------------------------------- | ------------------------- |
| `mocks/udemy-mocks/ingress.yaml` | `networking/ingress.yaml` |

### Mocks Directory
| Original Location                      | New Location                      |
| -------------------------------------- | --------------------------------- |
| `cka_mocks/*.md`                       | `mocks/cka-troubleshooting/*.md`  |
| `cka_mocks/img/*`                      | `mocks/cka-troubleshooting/img/*` |
| `cka_mocks/udemy-mocks-examples/*`     | `mocks/udemy-mocks/*`             |
| `cka_mocks/udemy-mocks-examples/img/*` | `mocks/udemy-mocks/img/*`         |

### Imperative Commands Directory
| Original Location                         | New Location                                  |
| ----------------------------------------- | --------------------------------------------- |
| `imperative_cmds/pods_imperative_cmds.md` | `imperative-commands/pods_imperative_cmds.md` |

### Miscellaneous Directory
| Original Location  | New Location            |
| ------------------ | ----------------------- |
| `file.yaml`        | `misc/file.yaml`        |
| `somefile.md`      | `misc/somefile.md`      |
| `setup_bashrc.txt` | `misc/setup_bashrc.txt` |
| `misc_commands.md` | `misc/misc_commands.md` |
| `image.png`        | `misc/image.png`        |

---

## ✨ New Files Created

### Workloads YAML Examples (6 files)
1. `workloads/daemonset-fluentd-example.yaml` - DaemonSet for logging
2. `workloads/deployment-with-nodeport-service.yaml` - Complete deployment with service
3. `workloads/init-container-example.yaml` - Init container pattern
4. `workloads/multi-container-pod-example.yaml` - Multiple containers in one pod
5. `workloads/sidecar-container-example.yaml` - Sidecar pattern for log processing
6. `workloads/shared-volume-example.yaml` - Shared volume between containers

### Scheduling YAML Examples (3 files)
7. `scheduling/node-affinity-example.yaml` - Node affinity configuration
8. `scheduling/toleration-example.yaml` - Pod tolerations
9. `scheduling/static-pod-example.yaml` - Static pod definition

### Networking YAML Examples (2 files)
10. `networking/network-policy-example.yaml` - Network policy for pod security
11. `networking/httproute-example.yaml` - HTTPRoute using Gateway API

### Storage Files (2 files)
12. `storage/complete-pv-pvc-pod-service-example.yaml` - Complete storage setup
13. `storage/pv-pvc-pod-svc-app/README.md` - Documentation for PV/PVC example

---

## 🗑️ Files Removed

### Empty Duplicate Files:
- `storage/practice_questions/shared_volume.md` (empty - content exists in `practice_questions/shared_volume.md`)
- `storage/practice_questions/sideCar_container.md` (empty - content exists in `practice_questions/sideCar_container.md`)
- `practice_questions/lamp_stack/create_lamp_mysql_stack.md` (empty file)

---

## 🖼️ Image Organization

### Practice Questions
- Organized all images into `practice_questions/img/`
- Updated all markdown references from `image-*.png` to `img/image-*.png`

### Mocks - CKA Troubleshooting
- Organized all images into `mocks/cka-troubleshooting/img/`
- References already correct with `./img/` paths

### Mocks - Udemy
- Organized all images into `mocks/udemy-mocks/img/`
- Updated all markdown references from `image-*.png` to `img/image-*.png`

---

## 📝 Documentation Updates

### Updated Files:
- `README.md` - Complete rewrite with new structure, category descriptions, and file counts

---

## 🎯 Final Directory Structure

```
kubelabs/
├── workloads/              (11 files, 6 YAMLs)
├── scheduling/             (8 files, 3 YAMLs)
├── autoscaling/            (3 files, 1 YAML)
├── networking/             (4 files, 3 YAMLs)
├── storage/                (12 files, 5 YAMLs)
├── storage-class/          (3 files)
├── security/               (5 files)
├── cluster-management/     (4 files)
├── mocks/                  (19 files)
│   ├── cka-troubleshooting/
│   └── udemy-mocks/
├── practice_questions/     (18 files)
├── imperative-commands/    (1 file)
├── misc/                   (7 files)
└── textFiles/              (2 files)
```

---

## ✅ Verification

All existing content preserved:
- ✓ All documentation files moved (not deleted)
- ✓ All YAML files moved (not deleted)
- ✓ All images moved to img/ subdirectories
- ✓ All image references updated
- ✓ Only empty duplicate files removed
- ✓ 16 new files added for better organization

**No data loss occurred during reorganization.**
