# Grafana & Prometheus Monitoring Role
This role installs and configures Prometheus, Node Exporter, NVIDIA DCGM Exporter, and Grafana for system monitoring.

## Installation
Run:
```bash
ansible-playbook -i inventory playbook.yml
```

## Variables
| Variable | Default | Description |
|----------|---------|-------------|
| grafana_version | latest | Version of Grafana to install |
| prometheus_version | latest | Version of Prometheus to install |
| grafana_admin_user | admin | Grafana admin user |
| grafana_admin_password | admin | Grafana admin password |

## Dashboard
A system monitoring dashboard will be deployed with CPU, RAM, and GPU usage graphs.
