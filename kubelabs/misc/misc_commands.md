```
To create docker-registry secret:

kubectl create secret docker-registry private-reg-cred --docker-username=dock_user --docker-password=dock_password --docker-email=dock_user@myprivateregistry.com --docker-server=myprivateregistry.com:5000 --dry-run=client

Create HPA:
kubectl autoscale deployment frontend-deployment --cpu-percent=70 --min=2 --max=10

Setting replicas:
kubectl -n dev-wl07 scale --replicas=5 deploy webapp-wl07

Using custom file as config:
kubectl config use-context research --kubeconfig=/root/my-kube-config

kubectl config current-context --kubeconfig=/root/my-kube-config

Setting image/Updating image of deployment:
kubectl set image deployment.apps/web nginx=myprivateregistry.com:5000/nginx:alpine
```
