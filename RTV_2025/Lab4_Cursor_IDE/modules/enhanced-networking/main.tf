# =============================================================================
# ENHANCED NETWORKING MODULE
# =============================================================================
# This module creates a production-ready VPC with multi-AZ subnets, NAT gateway,
# and proper routing for high availability and security.

# =============================================================================
# VPC RESOURCE
# =============================================================================
# Creates the main VPC with DNS support enabled for internal name resolution
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# =============================================================================
# VPC FLOW LOGS
# =============================================================================
# Enables VPC flow logging for network traffic monitoring and security analysis
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-vpc-flow-log"
    Environment = var.environment
    Project     = var.project_name
  }
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_log_group" {
  name              = "/aws/vpc/flow-logs/${var.environment}"
  retention_in_days = 7

  tags = {
    Name        = "${var.environment}-vpc-flow-log-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_log_role" {
  name = "${var.environment}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-vpc-flow-log-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "${var.environment}-vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# =============================================================================
# PUBLIC SUBNETS
# =============================================================================
# Creates public subnets across multiple availability zones for high availability
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "public"
  }
}

# =============================================================================
# PRIVATE SUBNETS
# =============================================================================
# Creates private subnets for application servers with no direct internet access
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.environment}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "private"
  }
}

# =============================================================================
# INTERNET GATEWAY
# =============================================================================
# Provides internet connectivity for public subnets
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# =============================================================================
# NAT GATEWAY RESOURCES
# =============================================================================
# Elastic IP for NAT Gateway - Provides static public IP for outbound traffic
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
    Project     = var.project_name
  }
}

# NAT Gateway - Enables private subnets to access internet for updates and downloads
resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name        = "${var.environment}-nat-gateway"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# ROUTE TABLES
# =============================================================================
# Public route table - Routes traffic to internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Private route table - Routes traffic through NAT gateway for internet access
resource "aws_route_table" "private" {
  count  = var.create_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
    Name        = "${var.environment}-private-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# =============================================================================
# ROUTE TABLE ASSOCIATIONS
# =============================================================================
# Associates public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associates private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = var.create_nat_gateway ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
