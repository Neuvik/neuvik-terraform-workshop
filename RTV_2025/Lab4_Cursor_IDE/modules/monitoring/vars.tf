# =============================================================================
# MONITORING MODULE VARIABLES
# =============================================================================
# Variables for the monitoring module configuration

variable "environment" {
  description = "Environment name for resource naming and tagging"
  type        = string
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where monitoring resources will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for monitoring server placement"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for monitoring server instances"
  type        = string
}
