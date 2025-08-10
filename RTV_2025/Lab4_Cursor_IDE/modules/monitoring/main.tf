# =============================================================================
# MONITORING MODULE
# =============================================================================
# This module deploys monitoring infrastructure including Prometheus and Grafana
# for comprehensive infrastructure monitoring and alerting.

# =============================================================================
# IAM ROLES AND POLICIES
# =============================================================================
# IAM role for monitoring instances with minimal required permissions
resource "aws_iam_role" "monitoring_role" {
  name = "${var.environment}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-monitoring-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM instance profile for monitoring instances
resource "aws_iam_instance_profile" "monitoring_profile" {
  name = "${var.environment}-monitoring-profile"
  role = aws_iam_role.monitoring_role.name
}

# IAM policy for CloudWatch monitoring
resource "aws_iam_role_policy" "monitoring_cloudwatch_policy" {
  name = "${var.environment}-monitoring-cloudwatch-policy"
  role = aws_iam_role.monitoring_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# =============================================================================
# MONITORING SECURITY GROUP
# =============================================================================
# Security group for monitoring servers with controlled access to monitoring ports
resource "aws_security_group" "monitoring" {
  name        = "${var.environment}-monitoring-sg"
  description = "Security group for monitoring servers (Prometheus and Grafana)"
  vpc_id      = var.vpc_id

  # Prometheus metrics endpoint
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Prometheus metrics endpoint"
  }

  # Grafana web interface
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana web interface"
  }

  # SSH access for administration
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access for server administration"
  }

  # All outbound traffic for updates and external service access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic for updates and external services"
  }

  tags = {
    Name        = "${var.environment}-monitoring-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# =============================================================================
# PROMETHEUS SERVER
# =============================================================================
# Prometheus server for metrics collection and storage
resource "aws_instance" "prometheus" {
  ami           = var.ami_id
  instance_type = "t3.medium" # Larger instance for monitoring workloads

  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.monitoring_profile.name

  # Cloud-init script for Prometheus installation and configuration
  user_data = templatefile("${path.module}/templates/prometheus-init.sh", {
    environment = var.environment
  })

  # Disable IMDSv1 and enable IMDSv2 for enhanced security
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  # This enables IMDSv2
  }

  # Enable detailed monitoring for better observability
  monitoring = true

  # Enable EBS optimization for better storage performance
  ebs_optimized = true

  # Enhanced root block device with encryption and adequate storage
  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    encrypted   = true

    tags = {
      Name        = "${var.environment}-prometheus-volume"
      Environment = var.environment
      Project     = var.project_name
    }
  }

  tags = {
    Name        = "${var.environment}-prometheus"
    Environment = var.environment
    Project     = var.project_name
    Role        = "monitoring"
  }
}

# =============================================================================
# GRAFANA SERVER
# =============================================================================
# Grafana server for metrics visualization and dashboards
resource "aws_instance" "grafana" {
  ami           = var.ami_id
  instance_type = "t3.small"

  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.monitoring_profile.name

  # Cloud-init script for Grafana installation and configuration
  user_data = templatefile("${path.module}/templates/grafana-init.sh", {
    environment = var.environment
  })

  # Disable IMDSv1 and enable IMDSv2 for enhanced security
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  # This enables IMDSv2
  }

  # Enable detailed monitoring for better observability
  monitoring = true

  # Enable EBS optimization for better storage performance
  ebs_optimized = true

  # Enhanced root block device with encryption and adequate storage
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true

    tags = {
      Name        = "${var.environment}-grafana-volume"
      Environment = var.environment
      Project     = var.project_name
    }
  }

  tags = {
    Name        = "${var.environment}-grafana"
    Environment = var.environment
    Project     = var.project_name
    Role        = "monitoring"
  }
}
