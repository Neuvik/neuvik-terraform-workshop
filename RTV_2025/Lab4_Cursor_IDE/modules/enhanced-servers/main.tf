# =============================================================================
# ENHANCED SERVERS MODULE
# =============================================================================
# This module deploys production-ready EC2 instances with enhanced security groups,
# encrypted storage, and proper tagging for operational excellence.

# =============================================================================
# IAM ROLES AND POLICIES
# =============================================================================
# IAM role for EC2 instance with minimal required permissions
resource "aws_iam_role" "server_role" {
  name = "${var.environment}-server-role"

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
    Name        = "${var.environment}-server-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM instance profile for EC2 instance
resource "aws_iam_instance_profile" "server_profile" {
  name = "${var.environment}-server-profile"
  role = aws_iam_role.server_role.name
}

# IAM policy for CloudWatch monitoring
resource "aws_iam_role_policy" "server_cloudwatch_policy" {
  name = "${var.environment}-server-cloudwatch-policy"
  role = aws_iam_role.server_role.id

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
# SECURITY GROUPS
# =============================================================================
# Security group for the main application server with controlled access
resource "aws_security_group" "server" {
  name        = "${var.environment}-server-sg"
  description = "Security group for production server with controlled access"
  vpc_id      = var.vpc_id

  # SSH access for administrative purposes
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access for server administration"
  }

  # HTTP access for web applications
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access for web applications"
  }

  # HTTPS access for secure web applications
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access for secure web applications"
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
    Name        = "${var.environment}-server-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# =============================================================================
# EC2 INSTANCE
# =============================================================================
# Production-ready EC2 instance with enhanced security and monitoring capabilities
resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.server.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.server_profile.name

  # Cloud-init script for automated server configuration
  user_data = templatefile("${path.module}/templates/server-init.sh", {
    environment = var.environment
    server_name = "server"
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

  # Enhanced root block device with encryption and optimized storage
  root_block_device {
    volume_size = 30
    volume_type = "gp3" # General Purpose SSD with better performance
    encrypted   = true  # Enables encryption at rest for data security

    tags = {
      Name        = "${var.environment}-server-volume"
      Environment = var.environment
      Project     = var.project_name
    }
  }

  tags = {
    Name        = "${var.environment}-server"
    Environment = var.environment
    Project     = var.project_name
    Role        = "server"
  }
}
