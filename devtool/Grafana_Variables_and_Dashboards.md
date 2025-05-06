# Grafana: Variables, Data Sources, and Persistent Dashboards

## 📋 Agenda
- Import Ready-Made Dashboards
- Variables and Dynamic Dashboards
- Links
- Tags
- Multiple Data Sources

---

## 1. 📦 Import Ready-Made Dashboards

### 🔍 Why Use Them?
- Quick setup
- Consistent visualization
- Community support
- Follows best practices
- Easy to customize
---
### Advantages of Ready made Dashboards
- Time saving
- Pre configured visualizations
- BestPractices
- Community support
- Integration with various Data Sources
- Customizable
---
### 🚀 How to Import
- Use Grafana.com dashboards
- Upload or paste JSON
- Customize after import:
  - Update variables & queries
  - Adjust panels
  - Change thresholds/alerts
---
### ✅ Best Practices for importing Dashboards
1. **Version Control**: Save a copy of the original dashboard JSON before making changes
2. **Documentation**: Add notes about why certain modifications were made
3. **Testing**: Verify all panels work with your data after import
4. **Sharing**: Consider contributing improvements back to the community
5. **Regular Updates**: Check for newer versions of popular dashboards periodically

B
---
### Dashboard customization after import
- Adjusting variables
- updating queries
- Panel Adjustments
- Dashboard settings


---

## 2. 🔄 Variables & Dynamic Dashboards

### 🎯 Purpose
Instead of hardcoding values, you can insert variables (like $instance or $environment) so that a single dashboard can
display data for different hosts, regions, or any other criteria dynamically.
- Avoid hardcoding
- Allow dashboards to adapt to:
  - Instance
  - Environment
  - Region

### 🔧 Types of Variables
- **Query**: e.g., `$instance`, populated from Prometheus
- ![image](https://github.com/user-attachments/assets/2910a599-79d7-4144-82ed-2a01a3cf8c9d)

- **Custom**: Fixed dropdown
- **Interval**: Auto time-based granularity
  Here's a clearer explanation of each term you're referencing, especially in the context of monitoring tools like Grafana or Prometheus dashboards:

---

### 🔹 **Time Range**

* **Definition**: The **overall window of time** you're viewing data for.
* **Example**: Last 1 hour, Last 24 hours, Last 7 days, etc.
* **Purpose**: Determines the start and end times for the data you want to visualize or query.

---

### 🔹 **Interval**

* **Definition**: The **granularity** or **step size** of the data points in the graph.
* **Example**: 1m (1 minute), 5m (5 minutes), 1h (1 hour)
* **Purpose**: Controls how often the data points are plotted—smaller intervals mean more detailed graphs.

---

### 🔹 **Auto Interval**

* **Definition**: A feature that **automatically selects an appropriate interval** based on your selected time range and the panel width.
* **Purpose**: Prevents overloading graphs with too many data points or making them too sparse.
* **Example**: If your time range is 24 hours, it might auto-select a 5-minute interval.

---

### 🔹 **Auto Interval Calculation**

* **Definition**: The **internal logic** used to calculate the best interval for your graph.
* **Formula (typical)**:

  ```
  interval = (Time Range) / (Resolution)
  $--internal
  $--rate_internal
  ```

  where **Resolution** is usually the number of pixels or maximum data points the graph can display.

---

### 🧠 Benefits
- Improved efficiency
- More interactive dashboards
- Reusable templates

---

## 3. 🔗 Links in Dashboards

### 📈 Use Cases
- Navigate between dashboards/panels
- Drill down into details
- Enhance workflow

### 🔗 Types
- Dashboard links
- Panel links
- Data links

---

## 4. 🏷 Tags for Organization

### 📌 Benefits
- Easier dashboard grouping
- Faster filtering & navigation
- Improved team collaboration

### ✔ Best Practices
- Keep names consistent
- Use meaningful tags like: `DevOps`, `Critical`, `Production`
- Update tags as projects evolve

---

## 5. 🌐 Multiple Data Sources

Grafana supports connecting and querying multiple data sources such as:
- Prometheus (`http://localhost:9090`)
- Node Exporter
- External services (e.g., instahyre.com)

---

## 🧰 Sample Prometheus Configuration

```json
{
  "title": "Node Exporter Full",
  "tags": ["team:infra", "env:prod", "svc:linux"]
}
```

---

## 🕓 Time and Interval Notes
- **Time Range**: Window of data being observed
- **Interval**: Data point granularity
  - Auto-calculated based on selected time range
