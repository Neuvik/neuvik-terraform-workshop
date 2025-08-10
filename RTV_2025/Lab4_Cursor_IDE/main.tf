# =============================================================================
# LAB 4: ENHANCED INFRASTRUCTURE WITH MONITORING AND PRODUCTION BEST PRACTICES
# =============================================================================
# This configuration builds upon Lab 3's modules with production improvements
# including enhanced networking, monitoring stack, and cost analysis capabilities.

# =============================================================================
# TERRAFORM CONFIGURATION BLOCK
# =============================================================================
# Defines required Terraform version and provider versions for consistent deployments
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80" # Latest AWS provider version as of December 2024
    }
  }
}

# =============================================================================
# AWS PROVIDER CONFIGURATION
# =============================================================================
# Configures the AWS provider with region and default tags for all resources
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      Workshop    = "neuvik-lab4"
    }
  }
}

# =============================================================================
# DATA SOURCES
# =============================================================================
# Retrieves the latest Ubuntu 22.04 LTS AMI for EC2 instance deployments
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =============================================================================
# MODULE CONFIGURATIONS
# =============================================================================

# Enhanced VPC Module - Creates production-ready networking infrastructure
module "enhanced_networking" {
  source = "./modules/enhanced-networking"

  environment        = var.environment
  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  create_nat_gateway = var.create_nat_gateway
}

# Enhanced Servers Module - Deploys production-ready EC2 instances
module "enhanced_servers" {
  source = "./modules/enhanced-servers"

  environment        = var.environment
  project_name       = var.project_name
  vpc_id             = module.enhanced_networking.vpc_id
  public_subnet_ids  = module.enhanced_networking.public_subnet_ids
  private_subnet_ids = module.enhanced_networking.private_subnet_ids
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = var.instance_type
  key_name           = aws_key_pair.lab4_key.key_name
}

# Monitoring Module - Deploys Prometheus and Grafana monitoring stack
module "monitoring" {
  source = "./modules/monitoring"

  environment      = var.environment
  project_name     = var.project_name
  vpc_id           = module.enhanced_networking.vpc_id
  vpc_cidr         = var.vpc_cidr
  public_subnet_id = module.enhanced_networking.public_subnet_ids[0]
  ami_id           = data.aws_ami.ubuntu.id
}
