#!/bin/bash
# =============================================================================
# PROMETHEUS INITIALIZATION SCRIPT
# =============================================================================
# This script installs and configures Prometheus for metrics collection
# and monitoring of the Lab 4 infrastructure.

set -e

# Update system packages
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install essential packages
echo "Installing essential packages..."
apt-get install -y \
    curl \
    wget \
    git \
    htop \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Create prometheus user
echo "Creating prometheus user..."
useradd --no-create-home --shell /bin/false prometheus

# Create directories
echo "Creating Prometheus directories..."
mkdir -p /etc/prometheus
mkdir -p /var/lib/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Download and install Prometheus
echo "Downloading and installing Prometheus..."
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz
tar xvf prometheus-2.48.0.linux-amd64.tar.gz
cp prometheus-2.48.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.48.0.linux-amd64/promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

# Copy configuration files
cp -r prometheus-2.48.0.linux-amd64/consoles /etc/prometheus
cp -r prometheus-2.48.0.linux-amd64/console_libraries /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus

# Create Prometheus configuration
echo "Creating Prometheus configuration..."
cat > /etc/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'nginx-exporter'
    static_configs:
      - targets: ['localhost:9113']

  - job_name: 'cloudwatch'
    static_configs:
      - targets: ['localhost:9106']
EOF

chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Create systemd service
echo "Creating Prometheus systemd service..."
cat > /etc/systemd/system/prometheus.service << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

# Install Node Exporter
echo "Installing Node Exporter..."
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvf node_exporter-1.6.1.linux-amd64.tar.gz
cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/node_exporter

# Create Node Exporter systemd service
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Start and enable services
echo "Starting and enabling services..."
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl enable node_exporter
systemctl start node_exporter

# Create a simple status page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Prometheus Server - Lab 4</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .link { margin: 10px 0; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Prometheus Monitoring Server</h1>
            <p>Environment: ${environment}</p>
            <p>Lab 4 Infrastructure Monitoring</p>
        </div>
        <h2>Monitoring Links</h2>
        <div class="link">
            <a href="http://localhost:9090" target="_blank">Prometheus Web UI</a>
        </div>
        <div class="link">
            <a href="http://localhost:9100/metrics" target="_blank">Node Exporter Metrics</a>
        </div>
        <h2>Server Information</h2>
        <ul>
            <li><strong>Hostname:</strong> $(hostname)</li>
            <li><strong>IP Address:</strong> $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</li>
            <li><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</li>
        </ul>
    </div>
</body>
</html>
EOF

# Install nginx for the status page
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

echo "Prometheus initialization completed successfully!"
echo "Environment: ${environment}"
echo "Prometheus is available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9090"
echo "Node Exporter metrics at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9100/metrics"
