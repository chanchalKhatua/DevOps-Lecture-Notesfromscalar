### Problem statement:

![alt text](img/image.png)

```
apiVersion: v1
kind: Pod
metadata:
  name: webserver
  labels:
    run: webserver
spec:
  volumes:
    - name: shared-logs
      emptyDir: {}

  containers:
    - name: nginx-container
      image: nginx:latest
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx

    - name: sidecar-container
      image: ubuntu:latest
      command: ["sh","-c","while true; do cat /var/log/nginx/access.log /var/log/nginx/error.log; sleep 30; done"]
      volumeMounts:
        - name: shared-logs
          mountPath: /var/log/nginx
```

---

## Key Points: Sidecar vs Init Container

### Why the Pod Gets Stuck
- `sidecar-container` is mistakenly placed under `initContainers:` instead of `containers:`.
- **Init containers** must finish and exit successfully before any regular container starts.
- If your init container runs an infinite loop (e.g., `while true; do ...; done`), it never exits.
- Result: Pod status remains `Init:0/1` forever.

### What Happens in This Scenario
- `nginx-container` never starts because the init container never finishes.
- Log files (`/var/log/nginx/access.log`, `/var/log/nginx/error.log`) do not exist yet.
- Log output shows errors like:
  ```
  cat: /var/log/nginx/access.log: No such file or directory
  ```
- This is expected: init is running, nginx isn’t.

### Summary
- Pod is stuck in the init phase.
- Logs complain because files don’t exist yet.
- Pod never reaches Running state.

---

## Quick Mental Model
- **Init container + infinite loop = pod never becomes Running.**
- **Sidecar = regular container, not init.** Runs alongside the main app, not before it.
- Apply this rule of thumb to avoid getting stuck in `Init:0/1` again.
---