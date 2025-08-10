# =============================================================================
# LAB 4 VARIABLES CONFIGURATION
# =============================================================================
# This file defines all variables used throughout the Lab 4 infrastructure
# with appropriate defaults and descriptions for production deployment.

# =============================================================================
# AWS CONFIGURATION VARIABLES
# =============================================================================
variable "region" {
  description = "AWS region where all resources will be deployed"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# ENVIRONMENT AND PROJECT VARIABLES
# =============================================================================
variable "environment" {
  description = "Environment name used for resource naming and tagging (e.g., dev, staging, prod)"
  type        = string
  default     = "lab4"
}

variable "project_name" {
  description = "Project name used for resource tagging and organization"
  type        = string
  default     = "neuvik-workshop"
}

# =============================================================================
# NETWORKING VARIABLES
# =============================================================================
variable "vpc_cidr" {
  description = "CIDR block for the main VPC (e.g., 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets across multiple AZs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets across multiple AZs"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones for subnet placement"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

# =============================================================================
# COMPUTE VARIABLES
# =============================================================================
variable "instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2 instance access"
  type        = string
  default     = "lab4-key" # Default to our generated key pair
}
