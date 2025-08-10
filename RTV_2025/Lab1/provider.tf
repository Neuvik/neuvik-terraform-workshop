# Terraform configuration block specifying required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"  # Latest AWS provider version as of December 2024
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  
  # Optional: Add default tags to all resources
  default_tags {
    tags = {
      Environment = "terraform-workshop"
      Project     = "neuvik-lab1"
      ManagedBy   = "terraform"
    }
  }
}