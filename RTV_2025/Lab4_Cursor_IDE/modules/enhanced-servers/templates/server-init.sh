#!/bin/bash
# =============================================================================
# SERVER INITIALIZATION SCRIPT
# =============================================================================
# This script configures a production-ready Ubuntu server with security updates,
# monitoring tools, and basic web server setup.

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

# Install and configure nginx
echo "Installing and configuring nginx..."
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# Create a simple welcome page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Lab 4 Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Welcome to Lab 4 Server</h1>
            <p>Environment: ${environment}</p>
            <p>Server Name: ${server_name}</p>
            <p>Deployed with Terraform and enhanced with production best practices!</p>
        </div>
        <h2>Server Information</h2>
        <ul>
            <li><strong>Hostname:</strong> $(hostname)</li>
            <li><strong>IP Address:</strong> $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)</li>
            <li><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</li>
            <li><strong>Region:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/region)</li>
        </ul>
    </div>
</body>
</html>
EOF

# Configure nginx
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html index.htm;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
EOF

# Test nginx configuration and reload
nginx -t && systemctl reload nginx

# Install CloudWatch agent for monitoring
echo "Installing CloudWatch agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json << 'EOF'
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/aws/ec2/nginx-access",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/aws/ec2/nginx-error",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "Lab4/Server",
        "metrics_collected": {
            "cpu": {
                "measurement": ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"],
                "metrics_collection_interval": 60,
                "totalcpu": false
            },
            "disk": {
                "measurement": ["used_percent"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "diskio": {
                "measurement": ["io_time"],
                "metrics_collection_interval": 60,
                "resources": ["*"]
            },
            "mem": {
                "measurement": ["mem_used_percent"],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": ["tcp_established", "tcp_time_wait"],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": ["swap_used_percent"],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Create a simple health check endpoint
cat > /var/www/html/health << 'EOF'
OK
EOF

echo "Server initialization completed successfully!"
echo "Environment: ${environment}"
echo "Server Name: ${server_name}"
echo "Server is ready for production use!"
