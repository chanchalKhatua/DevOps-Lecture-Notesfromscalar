# HPA stands for Horizontal Pod Autoscaler.
What it does:

  Automatically adjusts the number of Pods in a Deployment, StatefulSet, or ReplicaSet based on CPU/memory usage or custom metrics.

TL;DR:

It's Kubernetes saying:
"Oh, you're under pressure? Here's another Pod buddy to help you out." 💪
```
kubectl autoscale deployment my-app --cpu-percent=50 --min=2 --max=10
```
This will:

  * Keep CPU usage around 50%.

  * Never scale below 2 pods or above 10.

## Example:

### Create an autoscaler for the nginx-deployment with a maximum of 3 replicas and a CPU utilization target of 80%.
