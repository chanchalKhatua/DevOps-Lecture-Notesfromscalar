
# Prometheus Monitoring Configuration

## Agenda

- Introduction to Prometheus  
- Challenges with 100 Microservices in Kubernetes  
- Metrics Overload  
- Central View & Tool Fragmentation  
- Manual Monitoring Issues  

---

## 1. Introduction to Prometheus


### Challenges with 100 Microservices in Kubernetes

- Too many metrics  
- Data overload  
- No central view  
- Tool fragmentation  
- Manual monitoring  

Prometheus is an **open-source monitoring and alerting system** designed for **reliability, scalability, and flexibility**—especially in **cloud-native** and **containerized** environments like Kubernetes.

---

### Prometheus is used to:

- Monitor **microservices** (Kubernetes, Docker)
- Track **infrastructure metrics** (CPU, RAM, Disk)
- Alert when services misbehave (e.g., latency > X ms)
- Analyze long-term trends

---

### What we want in a monitoring tool:

- Centralized data  
- Easy queries  
- Automation  
- Alerts  
- Metrics stored in TSDB  
- Query, visualize, and alert

---

### Integrates with:

- **Grafana** – Dashboards  
- **Alertmanager** – Notifications  
- **Node Exporter**, **cAdvisor**, **Kube-State-Metrics**, etc.


---

## 2. Prometheus Architecture

### Components:

1. Prometheus Server  
2. Time Series Database (TSDB)  
3. Prometheus Targets  
4. Prometheus Exporters  
5. Push Gateway  
6. Alertmanager  
7. Data Visualization & Export

### Core Concepts:

- **Retrieval**: Pulls metrics from targets
- **TSDB**: Stores time-stamped metrics
- **HTTP Server**: API, UI, PromQL, integrations

### Time Series Database (TSDB):

- Stores time-indexed data
- Efficient compression and querying
- Aggregation & downsampling

**Examples**:
- "What was CPU usage between 10:00 and 10:30?"
- "Average memory usage over last 24 hours"
- Downsampling: Save one data point every 10 minutes after a day

---

## 3. Prometheus Targets

A **target** is any endpoint that exposes metrics.

```yaml
scrape_configs:
  - job_name: 'myapp'
    static_configs:
      - targets: ['localhost:9090', '192.168.1.10:8080']
```

**Target Labels**:
- `__address__`: IP and port
- `job`: From config
- Additional: environment, instance, container

Prometheus sends `GET <target>:<port>/metrics`

---

## 4. Exporters

Exporters convert non-native metrics into Prometheus format:

- Collects system metrics (e.g., DB, OS)
- Exposes `/metrics` over HTTP

### Node Exporter:

1. Install Node Exporter  
2. Exposes `/metrics` on port `9100`  
3. Prometheus scrapes `http://<ip>:9100/metrics`

**Sample Metrics**:
```text
node_cpu_seconds_total{cpu="0", mode="user"} 1532.3
node_memory_MemAvailable_bytes 4385673216
```

---

## 5. Prometheus Installation (Docker Compose)

```yaml
version: "3"
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - monitoring

  node_exporter:
    image: prom/node-exporter:latest
    container_name: node_exporter
    ports:
      - "9100:9100"
    networks:
      - monitoring

volumes:
  prometheus_data:

networks:
  monitoring:
    driver: bridge
```

---

## 6. Scraping Configuration

### Sample `prometheus.yml`

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['node_exporter:9100']
```

### More Examples:

```yaml
scrape_configs:
  - job_name: 'app_metrics'
    static_configs:
      - targets: ['localhost:8080']
```

---

## 7. Labels in Prometheus

Labels provide context to metrics:

```text
http_requests_total{method="GET", status="200"}
```

### Label Types:

- **Static**:
```yaml
labels:
  env: 'production'
  service: 'frontend'
```

- **Dynamic** (e.g. Kubernetes metadata):
```yaml
__meta_kubernetes_pod_name="nginx-abc123"
```

---

## 8. Relabeling Demo

Used to transform or rename labels dynamically:

```yaml
relabel_configs:
  - source_labels: [__meta_kubernetes_pod_name]
    target_label: pod
    action: replace
```

---

## 9. Client Libraries

Client libraries let developers expose custom metrics:

### Example with Python (`prometheus_client`):

```python
from prometheus_client import Counter, Gauge, start_http_server
import time

# Define metrics
http_requests_total = Counter('http_requests_total', 'Total HTTP requests')
http_request_duration_seconds = Gauge('http_request_duration_seconds', 'Request duration in seconds')

def simulate_request():
    http_requests_total.inc()
    duration = 0.5
    http_request_duration_seconds.set(duration)
    time.sleep(duration)

if __name__ == '__main__':
    start_http_server(8000)
    while True:
        simulate_request()
        time.sleep(1)
```

### Dockerfile for Custom Exporter:

```Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "app.py"]
```

**`requirements.txt`:**
```
prometheus_client
```
