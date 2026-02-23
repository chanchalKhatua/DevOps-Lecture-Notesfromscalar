# Docker Commands Cheat Sheet

## Getting Started with Docker

### Check Docker Version
```sh
docker --version
```
- Displays the installed Docker version.

### Run a Simple Container
```sh
docker run hello-world
```
- Runs a basic container to verify Docker installation.

---

## Container Management

### List Running Containers
```sh
docker ps
```
- Shows currently running containers.

### List All Containers (including stopped ones)
```sh
docker ps -a
```
- Displays all containers, including stopped ones.

### Start a Container
```sh
docker start <container_id>
```
- Starts a stopped container.

### Stop a Container
```sh
docker stop <container_id>
```
- Stops a running container.

### Restart a Container
```sh
docker restart <container_id>
```
- Restarts a running or stopped container.

### Remove a Container
```sh
docker rm <container_id>
```
- Deletes a stopped container.

### Remove All Stopped Containers
```sh
docker container prune
```
- Deletes all stopped containers.

---

## Image Management

### List Docker Images
```sh
docker images
```
- Displays all locally stored images.

### Pull an Image from Docker Hub
```sh
docker pull <image_name>
```
- Downloads a Docker image.

### Remove an Image
```sh
docker rmi <image_id>
```
- Deletes a Docker image.

### Build an Image from a Dockerfile
```sh
docker build -t <image_name> .
```
- Creates an image using a Dockerfile.

---

## Working with Docker Volumes

### List Volumes
```sh
docker volume ls
```
- Displays all Docker volumes.

### Create a Volume
```sh
docker volume create <volume_name>
```
- Creates a new volume.

### Remove a Volume
```sh
docker volume rm <volume_name>
```
- Deletes a volume.

### Remove All Unused Volumes
```sh
docker volume prune
```
- Deletes unused volumes.

---

## Networking in Docker

### List Networks
```sh
docker network ls
```
- Displays all Docker networks.

### Create a Network
```sh
docker network create <network_name>
```
- Creates a new network.

### Connect a Container to a Network
```sh
docker network connect <network_name> <container_id>
```
- Adds a container to a network.

### Disconnect a Container from a Network
```sh
docker network disconnect <network_name> <container_id>
```
- Removes a container from a network.

---

## Docker Logs and Monitoring

### View Container Logs
```sh
docker logs <container_id>
```
- Displays the logs of a container.

### Follow Real-time Logs
```sh
docker logs -f <container_id>
```
- Streams container logs in real-time.

### Display Running Container Stats
```sh
docker stats
```
- Shows CPU, memory, and network usage of running containers.

---

## Docker Compose

### Start Services in Docker Compose
```sh
docker-compose up -d
```
- Starts services defined in `docker-compose.yml`.

### Stop Services in Docker Compose
```sh
docker-compose down
```
- Stops and removes containers, networks, and volumes defined in `docker-compose.yml`.

---

## Cleanup Commands

### Remove All Stopped Containers, Unused Networks, and Build Cache
```sh
docker system prune
```
- Cleans up unused resources.

### Remove Everything (Containers, Images, Networks, Volumes)
```sh
docker system prune -a
```
- Removes all stopped containers, images, networks, and volumes.

---

## Additional Resources
For more details, visit the official Docker documentation: [Docker Docs](https://docs.docker.com/)
