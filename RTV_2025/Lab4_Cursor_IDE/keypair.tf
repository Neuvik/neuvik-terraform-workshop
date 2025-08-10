# =============================================================================
# SSH KEY PAIR CONFIGURATION
# =============================================================================
# This file manages the SSH key pair for EC2 instance access

# =============================================================================
# AWS KEY PAIR
# =============================================================================
# Creates an AWS key pair using the local public key file
resource "aws_key_pair" "lab4_key" {
  key_name   = "${var.environment}-key"
  public_key = file("${path.module}/lab4-key.pub")

  tags = {
    Name        = "${var.environment}-key"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
