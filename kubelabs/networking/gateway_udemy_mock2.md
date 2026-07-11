### Problem statment: Modify the existing web-gateway on cka5673 namespace to handle HTTPS traffic on port 443 for kodekloud.com, using a TLS certificate stored in a secret named kodekloud-tls.

```
---
# My solution
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: cka5673
spec:
  gatewayClassName: kodekloud
  listeners:
    - hostname: kodekloud.com
      name: https
      port: 443
      protocol: HTTPS
      tls:
        certificateRefs:
          - name: kodekloud-tls
---
# Answer: web-gateway.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: cka5673
spec:
  gatewayClassName: kodekloud
  listeners:
    - name: https
      protocol: HTTPS
      port: 443
      hostname: kodekloud.com
      tls:
        certificateRefs:
          - name: kodekloud-tls
```

Note: I am unable to find the diff between the answer and my yaml, However when I was applying my yaml it was incorrect in evaluation. Later when I applied my yaml post copying the answer yaml I was accepted. Weird! Eh. But what to do. Enjoy! :) 


Reference of Mock 2 Notes with solution:

https://notes.kodekloud.com/docs/CKA-Certification-Course-Certified-Kubernetes-Administrator/Mock-Exams/Mock-Exam-2-Step-by-Step-Solutions