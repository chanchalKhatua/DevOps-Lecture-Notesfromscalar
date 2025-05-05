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
### ✅ Best Practices
- Save original JSON (for version control)
- Document changes
- Test panel functionality
- Share improvements back
- Check for updates regularly
---
### Dashboard customization after import
- Adjusting variables
- updating queries
- Panel Adjustments
- Dashboard settings
---

## 2. 🔄 Variables & Dynamic Dashboards

### 🎯 Purpose
- Avoid hardcoding
- Allow dashboards to adapt to:
  - Instance
  - Environment
  - Region

### 🔧 Types of Variables
- **Query**: e.g., `$instance`, populated from Prometheus
- **Custom**: Fixed dropdown
- **Interval**: Auto time-based granularity

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
