# Welcome to Lab 4 - Advanced Infrastructure with Monitoring and Production Best Practices

Welcome to the final lab in our Terraform workshop! In this lab, you'll build upon everything you've learned in Labs 1-3 to create a production-ready infrastructure with monitoring, cost analysis, and advanced automation. You'll learn how to use Cursor IDE's AI capabilities to enhance your Terraform code and implement industry best practices.

## What You'll Build

In this lab, you'll create a comprehensive infrastructure that includes:

1. **Enhanced Modular Infrastructure** - Building upon Lab 3's modules with production improvements
2. **Monitoring Stack** - Prometheus and Grafana for infrastructure monitoring
3. **Cost Analysis** - Using Infracost to understand and optimize costs
4. **Production Best Practices** - Security, scalability, and maintainability improvements
5. **AI-Enhanced Development** - Leveraging Cursor IDE's AI capabilities for code improvements

## Prerequisites

Before starting this lab, ensure you have completed:

✅ **Lab 1** - Basic VPC creation and Terraform fundamentals  
✅ **Lab 2** - EC2 instances with cloud-init templates  
✅ **Lab 3** - Terraform modules and reusable components  

You'll also need:

- **Cursor IDE** with AI capabilities enabled
- **Terraform** version 1.12 or higher
- **AWS Account** with appropriate permissions
- **Infracost** installed for cost analysis
- **Basic understanding** of monitoring concepts

## Getting Started

**Step 1.** Open Cursor IDE and navigate to the Lab4 directory:

```bash
cd ../Lab4
```

You can use Cursor IDE's file explorer to navigate to the `Lab4` folder, or use the integrated terminal (Ctrl/Cmd + `) to run the command above.

## Setting Up the Foundation

**Step 2.** Let's start by copying and enhancing the infrastructure from Lab 3. In Cursor IDE, create a new file called `main.tf`:

- Right-click in the file explorer and select "New File"
- Name it `main.tf`
- Or use `Ctrl/Cmd + N` to create a new file and save it as `main.tf`

**Step 3.** We'll use Cursor IDE's AI capabilities to help us create an enhanced version of our Lab 3 infrastructure. In the new `main.tf` file, start by adding a comment and then use Cursor's AI to help generate the code:

```hcl
# Enhanced Infrastructure for Lab 4
# This builds upon Lab 3's modules with production improvements

# TODO: Use Cursor IDE's AI to help generate enhanced module configurations
```

**Step 4.** Now let's use Cursor IDE's AI to help us improve our modules. In Cursor IDE:

1. Select the comment block you just created
2. Press `Ctrl/Cmd + K` to open the AI chat
3. Ask: "Help me create an enhanced version of the Lab 3 VPC and server modules with production best practices, including proper tagging, security groups, and monitoring capabilities"

The AI should help you generate improved module configurations.

## Creating Enhanced Modules

**Step 5.** Let's create an enhanced VPC module. In Cursor IDE, create a new directory structure:

```bash
mkdir -p modules/enhanced-networking
mkdir -p modules/enhanced-servers
mkdir -p modules/monitoring
```

**Step 6.** Create the enhanced networking module. In Cursor IDE, create `modules/enhanced-networking/main.tf`:

```hcl
# Enhanced VPC with production best practices
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

# Enhanced public subnets across multiple AZs
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

# Enhanced private subnets for application servers
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

# Internet Gateway with enhanced tagging
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# NAT Gateway for private subnet internet access
resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
    Project     = var.project_name
  }
}

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

# Enhanced route tables
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

# Route table associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = var.create_nat_gateway ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
```

## Adding Monitoring Infrastructure

**Step 7.** Create the monitoring module. In Cursor IDE, create `modules/monitoring/main.tf`:

```hcl
# Prometheus Server
resource "aws_instance" "prometheus" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"  # Larger instance for monitoring

  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/prometheus-init.sh", {
    environment = var.environment
  })

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

# Grafana Server
resource "aws_instance" "grafana" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/grafana-init.sh", {
    environment = var.environment
  })

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

# Enhanced security group for monitoring
resource "aws_security_group" "monitoring" {
  name        = "${var.environment}-monitoring-sg"
  description = "Security group for monitoring servers"
  vpc_id      = var.vpc_id

  # Prometheus metrics
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Grafana web interface
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-monitoring-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}
```

## Implementing Cost Analysis

**Step 8.** Install and configure Infracost for cost analysis. In Cursor IDE's integrated terminal:

```bash
# Install Infracost (if not already installed)
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Initialize Infracost
infracost auth login
```

**Step 9.** Create an Infracost configuration file. In Cursor IDE, create `infracost.yml`:

```yaml
version: 0.1

projects:
  - path: .
    name: lab4-infrastructure
    terraform_var_files:
      - terraform.tfvars
```

**Step 10.** Generate a cost estimate. In Cursor IDE's integrated terminal:

```bash
infracost breakdown --path . --format table
```

This will show you the estimated monthly cost of your infrastructure.

## Using Cursor IDE's AI for Code Enhancement

**Step 11.** Let's use Cursor IDE's AI to improve our code. In Cursor IDE:

1. Select a section of your Terraform code
2. Press `Ctrl/Cmd + K` to open the AI chat
3. Ask: "How can I improve this Terraform configuration for production use? Consider security, scalability, and best practices."

**Step 12.** Apply the AI suggestions to enhance your code. Common improvements might include:

- Adding more comprehensive tagging
- Implementing proper IAM roles and policies
- Adding CloudWatch monitoring
- Implementing backup strategies
- Adding auto-scaling groups

## Validation and Testing

**Step 13.** Run comprehensive validation. In Cursor IDE's integrated terminal:

```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Run linter
tflint

# Security scanning
checkov -d .

# Cost analysis
infracost breakdown --path . --format table
```

**Step 14.** Plan and apply your infrastructure:

```bash
terraform plan -out lab4.plan
terraform apply lab4.plan
```

## Monitoring Setup

**Step 15.** After the infrastructure is deployed, set up monitoring:

1. **Access Prometheus**: Navigate to `http://[prometheus-public-ip]:9090`
2. **Access Grafana**: Navigate to `http://[grafana-public-ip]:3000`
3. **Configure dashboards** in Grafana to monitor your infrastructure
4. **Set up alerts** for critical metrics

## Production Best Practices Implementation

**Step 16.** Implement additional production features:

### Backup Strategy
```hcl
# Add to your main configuration
resource "aws_backup_vault" "main" {
  name = "${var.environment}-backup-vault"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
```

### CloudWatch Monitoring
```hcl
# Enhanced monitoring for EC2 instances
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${var.environment}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  
  dimensions = {
    InstanceId = aws_instance.bastion.id
  }
}
```

## Cleanup and Documentation

**Step 17.** Create comprehensive documentation. In Cursor IDE, create `README.md` in your Lab4 directory:

```markdown
# Lab 4 Infrastructure Documentation

## Overview
This infrastructure includes:
- Enhanced VPC with multi-AZ subnets
- Production-ready EC2 instances
- Prometheus and Grafana monitoring
- Cost optimization with Infracost
- Security best practices

## Architecture
[Include a diagram or description of your infrastructure]

## Monitoring
- Prometheus: [URL]
- Grafana: [URL] (admin/admin)

## Cost Analysis
Monthly estimated cost: $[amount]

## Security Features
- Encrypted EBS volumes
- Security groups with minimal access
- IAM roles and policies
- VPC with private subnets

## Maintenance
- Regular backups via AWS Backup
- CloudWatch monitoring and alerts
- Automated scaling policies
```

**Step 18.** Clean up your resources when finished:

```bash
terraform destroy -auto-approve
```

## Cursor IDE Tips for Advanced Development

1. **AI Code Review**: Use `Ctrl/Cmd + K` to ask AI to review your Terraform code
2. **Code Generation**: Ask AI to generate boilerplate code for common patterns
3. **Best Practices**: Use AI to suggest security and performance improvements
4. **Documentation**: Ask AI to help generate documentation for your infrastructure
5. **Troubleshooting**: Use AI to help debug Terraform issues

## What You've Learned

In this lab, you've successfully:

✅ **Enhanced modular infrastructure** with production best practices  
✅ **Implemented comprehensive monitoring** with Prometheus and Grafana  
✅ **Analyzed costs** using Infracost for optimization  
✅ **Leveraged Cursor IDE's AI** for code improvements  
✅ **Applied security best practices** including encryption and IAM  
✅ **Created production-ready infrastructure** with proper tagging and documentation  

## Next Steps

You've now completed the full Terraform workshop! Consider exploring:

- **Terraform Cloud** for team collaboration and remote state management
- **Terraform Enterprise** for advanced features and governance
- **Infrastructure as Code patterns** for different cloud providers
- **Advanced monitoring** with custom metrics and dashboards
- **CI/CD integration** with GitHub Actions or GitLab CI

---

**Congratulations on completing the Terraform Workshop!** You now have the skills to build production-ready infrastructure using Infrastructure as Code with Terraform and Cursor IDE. 🚀