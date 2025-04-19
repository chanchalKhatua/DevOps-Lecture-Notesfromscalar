
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
![image](https://github.com/user-attachments/assets/644683ea-ad1a-4c29-9b2e-3e61669b0946)

### Components:

1. Prometheus Server  
2. Time Series Database (TSDB)  
3. Prometheus Targets  
4. Prometheus Exporters  
5. Push Gateway  
6. Alertmanager  
7. Data Visualization & Export

---

## 📊 PROMETHEUS ARCHITECTURE – DETAILED POINTWISE EXPLANATION

---

### ✅ 1. **Prometheus Server**
- **Retrieval**: Responsible for pulling metrics from configured targets (like Node Exporter, application endpoints, or
Pushgateway).
- **TSDB (Time Series Database)**: Stores the metrics as time-stamped series data. Each metric is identified by a name
and label set.
- **HTTP Server**: Exposes APIs and web UI, allows querying via PromQL, and integrates with visualization tools and
Alertmanager
- **Running PromQL queries** for data analysis.
- **Exposing APIs** for other systems (e.g., Grafana, Alertmanager).

📝 **Key Features:**
- Pull-based model (Prometheus scrapes the data).
- Uses HTTP protocol.
- Easy configuration via `prometheus.yml`.

---

### ✅ 2. **TSDB (Time Series Database)**
A **Time Series Database** is a **specialized database designed to store and manage data that changes over time** called **time series data**.

📝 **Key Concepts:**
- Each data point has:
  - **Metric Name**
  - **Timestamp**
  - **Value**
  - **Labels** (e.g., instance, job, environment)
  
📌 **Features of TSDB:**
- Stores billions of data points efficiently.
- Indexes time-series data by metric and label combinations. Stores data points indexed by time
- Performing fast queries over time ranges
    - "What was the CPU usage between 10:00 and 10:30?"
    - "Show average memory usage over the last 24 hours"
    - "Find spikes in disk I/O during the last week"
- Compressing repetitive time-stamped data efficiently
- **Aggregation**: Compute averages, max, min, etc.
     - "Average CPU per 5 minutes"_
- **Downsampling**: Reduce resolution for long-term storage.
 - Instead of keeping data every second, keep **one value every 10 minutes** after a day


📊 **Example Data Points:**
```
Time     | Value
---------|-------
10:00    | 25.1
10:01    | 25.1
10:02    | 25.1
```

---

### ✅ 3. **Prometheus Targets**
A **target** is any service or endpoint that exposes metrics in a Prometheus-compatible format.

📝 **How It Works:**
- Prometheus is configured with `scrape_configs` in `prometheus.yml`.
- Each target is associated with a **job name**.
- It sends HTTP GET requests to:  
  `http://<target-ip>:<port>/metrics`

📘 **Example Config:**
```yaml
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

📌 **Target Discovery:**
- **Static Configuration** – Hardcoded in config file.
- **Dynamic Service Discovery** – Integrates with Kubernetes, EC2, Consul, etc.

🔖 **Metadata Labels**:
- Prometheus attaches metadata like:
  - `instance`
  - `job`
  - `environment`
  - `region`, etc.

---

### ✅ 4. **Prometheus Exporters**
Exporters are **bridge tools** that collect metrics from external systems and expose them to Prometheus.

📝 **Purpose:**
- Convert non-Prometheus-native metrics (OS, DBs, etc.) to Prometheus format.
- Expose them at a `/metrics` HTTP endpoint.

📌 **How Exporters Work:**
1. Exporter collects raw data from a system.
2. It formats the data into Prometheus format.
3. It exposes the metrics at `/metrics`.
4. Prometheus scrapes this endpoint.

📘 **Popular Exporters:**
- **Node Exporter**: For Linux system metrics (CPU, memory, disk).
- **Blackbox Exporter**: For endpoint probing (HTTP, TCP, DNS).
- **MySQL/Postgres Exporter**: For database metrics.

📊 **Node Exporter Example:**
```
node_cpu_seconds_total{cpu="0",mode="user"} 1532.3
node_memory_MemAvailable_bytes 4385673216
```

---

### ✅ 5. **Prometheus Push Gateway**
Used when you can’t scrape metrics (e.g., for **short-lived jobs**).

📝 **Purpose:**
- Allows **batch jobs** to push metrics to Prometheus indirectly.
- The Push Gateway **stores the metrics temporarily**, so Prometheus can scrape them.

📌 **Use Case Examples:**
- CI/CD pipelines
- Cron jobs
- Backup scripts

🧭 **Flow:**
1. Batch job finishes.
2. It pushes metrics to Push Gateway.
3. Prometheus scrapes metrics from Push Gateway.

⚠️ Not recommended for high-frequency jobs or long-running services.

---

### ✅ 6. **Alertmanager**
Handles alerts generated by Prometheus based on rules.

📝 **Purpose:**
- Send notifications via email, Slack, PagerDuty, webhooks, etc.
- Manage alert **routing**, **grouping**, **inhibition**, and **silencing**.

📘 **Features:**
- **Grouping**: Combine related alerts to reduce noise.
- **Routing**: Send alerts to different channels based on labels.
- **Silencing**: Suppress alerts during maintenance.
- **Deduplication**: Avoid repeated alert messages.

📌 **Example Rule:**
```yaml
groups:
- name: instance-down
  rules:
  - alert: InstanceDown
    expr: up == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      description: "{{ $labels.instance }} is down"
```

---

### ✅ 7. **Data Visualization and Export**
Prometheus integrates well with **dashboard tools** and supports **APIs** for querying/exporting.

📝 **Popular Tool: Grafana**
- Connects to Prometheus as a data source.
- Builds beautiful dashboards for real-time and historical data.

📘 **Other Visual/Export Options:**
- Prometheus Web UI: Built-in query interface (basic visual).
- Export data using API.
- Integrations with tools like Thanos, Cortex for long-term storage and multi-cluster metrics.

---

## 🔁 Prometheus Metrics Flow – Step-by-Step

1. **Retrieval**:
   - Prometheus pulls metrics from `/metrics` endpoints.

2. **TSDB Storage**:
   - Stores data points with timestamps and labels.

3. **Querying (PromQL)**:
   - Analyze data using the PromQL query language.
   - Example: `rate(http_requests_total[5m])`

4. **Alerting**:
   - Based on PromQL expressions, triggers alerts via Alertmanager.

5. **Visualization**:
   - Data is visualized using Grafana or built-in web UI.

6. **Optional**:
   - PushGateway accepts pushed metrics from batch jobs.

---

Would you like a **diagram** of this architecture or an example **project setup file** (like `prometheus.yml` + Node Exporter config)?


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
