## Example: Create the ingress resource to make the applications available at /wear and /watch on the Ingress service.
Also, make use of rewrite-target annotation field: -
```
nginx.ingress.kubernetes.io/rewrite-target: /
```
Ingress resource comes under the namespace scoped, so don't forget to create the ingress in the app-space namespace.
* Ingress Created
* Path: /wear
* Path: /watch
* Configure correct backend service for /wear
* Configure correct backend service for /watch
* Configure correct backend port for /wear service
* Configure correct backend port for /watch service

## Solution:

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: app-space
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx-example
  rules:
  - http:
      paths:
      - path: /watch
        pathType: Prefix
        backend:
          service:
            name: video-service
            port:
              number: 8080
      - path: /wear
        pathType: Prefix
        backend:
          service:
            name: wear-service
            port:
              number: 8080
```
