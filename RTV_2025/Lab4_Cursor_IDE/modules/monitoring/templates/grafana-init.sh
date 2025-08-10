#!/bin/bash
# =============================================================================
# GRAFANA INITIALIZATION SCRIPT
# =============================================================================
# This script installs and configures Grafana for metrics visualization
# and dashboard creation for the Lab 4 infrastructure.

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

# Add Grafana GPG key
echo "Adding Grafana GPG key..."
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -

# Add Grafana repository
echo "Adding Grafana repository..."
echo "deb https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list

# Update package list and install Grafana
echo "Installing Grafana..."
apt-get update
apt-get install -y grafana

# Start and enable Grafana
echo "Starting and enabling Grafana..."
systemctl enable grafana-server
systemctl start grafana-server

# Wait for Grafana to start
echo "Waiting for Grafana to start..."
sleep 10

# Create admin user and add Prometheus data source
echo "Configuring Grafana..."
cat > /tmp/grafana-setup.sh << 'EOF'
#!/bin/bash

# Wait for Grafana to be ready
until curl -s http://localhost:3000/api/health; do
    echo "Waiting for Grafana to be ready..."
    sleep 5
done

# Create admin user (admin/admin)
curl -X POST http://localhost:3000/api/admin/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Admin",
    "email": "admin@lab4.local",
    "login": "admin",
    "password": "admin"
  }'

# Add Prometheus data source
curl -X POST http://localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46YWRtaW4=" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://localhost:9090",
    "access": "proxy",
    "isDefault": true
  }'

echo "Grafana setup completed!"
EOF

chmod +x /tmp/grafana-setup.sh
/tmp/grafana-setup.sh &

# Create a simple status page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Grafana Server - Lab 4</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .link { margin: 10px 0; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .credentials { background: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Grafana Visualization Server</h1>
            <p>Environment: ${environment}</p>
            <p>Lab 4 Infrastructure Monitoring Dashboards</p>
        </div>
        
        <div class="credentials">
            <h3>Default Credentials</h3>
            <p><strong>Username:</strong> admin</p>
            <p><strong>Password:</strong> admin</p>
        </div>
        
        <h2>Monitoring Links</h2>
        <div class="link">
            <a href="http://localhost:3000" target="_blank">Grafana Web UI</a>
        </div>
        
        <h2>Server Information</h2>
        <ul>
            <li><strong>Hostname:</strong> $(hostname)</li>
            <li><strong>IP Address:</strong> $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</li>
            <li><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</li>
        </ul>
        
        <h2>Next Steps</h2>
        <ol>
            <li>Access Grafana at <a href="http://localhost:3000" target="_blank">http://localhost:3000</a></li>
            <li>Login with admin/admin</li>
            <li>Add Prometheus as a data source (if not already added)</li>
            <li>Import or create dashboards for monitoring</li>
        </ol>
    </div>
</body>
</html>
EOF

# Install nginx for the status page
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

echo "Grafana initialization completed successfully!"
echo "Environment: ${environment}"
echo "Grafana is available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
echo "Default credentials: admin/admin"
