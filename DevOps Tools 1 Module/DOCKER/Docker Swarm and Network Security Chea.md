# Docker Swarm and Network Security Cheat Sheet

## Docker Swarm Basics

### Initialize a Swarm
```sh
docker swarm init --advertise-addr <manager-ip>
```
- Initializes a new Swarm cluster with the specified manager IP.

### Join a Worker Node to the Swarm
```sh
docker swarm join --token <worker-token> <manager-ip>:2377
```
- Adds a worker node to the Swarm cluster.

### Join a Manager Node to the Swarm
```sh
docker swarm join --token <manager-token> <manager-ip>:2377
```
- Adds another manager node to the Swarm cluster.

### List Nodes in the Swarm
```sh
docker node ls
```
- Displays all nodes in the Swarm cluster.

### Remove a Node from the Swarm
```sh
docker node rm <node-id>
```
- Removes a specific node from the cluster.

### Leave the Swarm
```sh
docker swarm leave --force
```
- Makes a node leave the Swarm.

---

## Deploying Services in Swarm

### Create a Service
```sh
docker service create --name <service_name> -p 80:80 <image_name>
```
- Deploys a service with port mapping.

### List Services
```sh
docker service ls
```
- Shows all running services in the Swarm.

### Scale a Service
```sh
docker service scale <service_name>=3
```
- Adjusts the number of replicas for a service.

### Remove a Service
```sh
docker service rm <service_name>
```
- Deletes a running service.

---

## Docker Swarm Networking

### List Networks
```sh
docker network ls
```
- Shows all available networks.

### Create an Overlay Network
```sh
docker network create --driver overlay <network_name>
```
- Creates a new overlay network for multi-host communication.

### Attach a Service to a Network
```sh
docker service create --network <network_name> --name <service_name> <image>
```
- Deploys a service attached to a specific network.

### Remove a Network
```sh
docker network rm <network_name>
```
- Deletes a Docker network.

---

## Docker Swarm Security Best Practices

### Encrypt Swarm Traffic
```sh
docker swarm update --encrypt-traffic
```
- Enables encryption for communication between nodes.

### Restrict Node Access
- Use firewalls to allow only trusted nodes to communicate on port `2377`.
- Restrict SSH access to manager nodes.

### Manage Secrets Securely
```sh
docker secret create <secret_name> <file>
```
- Creates a secret stored in Swarm.

```sh
docker secret ls
```
- Lists stored secrets.

### Use Role-Based Access Control
- Grant minimal privileges to users and services.
- Rotate tokens and credentials periodically.

### Scan Images for Vulnerabilities
```sh
docker scan <image_name>
```
- Scans Docker images for security vulnerabilities.

### Enable Logging and Monitoring
- Use logging drivers (`json-file`, `syslog`, `fluentd`) for tracking activity.
- Implement monitoring tools like Prometheus and Grafana for Swarm metrics.

---

## Additional Resources
For more details, visit the official Docker documentation: [Docker Docs](https://docs.docker.com/)
