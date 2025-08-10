# =============================================================================
# LAB 4 OUTPUTS
# =============================================================================
# This file defines outputs for the Lab 4 infrastructure

# =============================================================================
# SSH KEY PAIR OUTPUTS
# =============================================================================
output "ssh_key_name" {
  description = "Name of the SSH key pair created for EC2 access"
  value       = aws_key_pair.lab4_key.key_name
}

output "ssh_key_fingerprint" {
  description = "Fingerprint of the SSH key pair"
  value       = aws_key_pair.lab4_key.fingerprint
}

# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.enhanced_networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.enhanced_networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.enhanced_networking.private_subnet_ids
}

# =============================================================================
# SERVER OUTPUTS
# =============================================================================
output "server_public_ip" {
  description = "Public IP address of the main server"
  value       = module.enhanced_servers.server_public_ip
}

output "server_private_ip" {
  description = "Private IP address of the main server"
  value       = module.enhanced_servers.server_private_ip
}

# =============================================================================
# MONITORING OUTPUTS
# =============================================================================
output "prometheus_public_ip" {
  description = "Public IP address of the Prometheus server"
  value       = module.monitoring.prometheus_public_ip
}

output "grafana_public_ip" {
  description = "Public IP address of the Grafana server"
  value       = module.monitoring.grafana_public_ip
}

# =============================================================================
# CONNECTION INSTRUCTIONS
# =============================================================================
output "connection_instructions" {
  description = "Instructions for connecting to the servers"
  value       = <<-EOT
    =============================================================================
    LAB 4 CONNECTION INSTRUCTIONS
    =============================================================================
    
    SSH Key Location: ${path.module}/lab4-key
    
    To connect to the servers:
    
    1. Main Server:
       ssh -i ${path.module}/lab4-key ubuntu@${module.enhanced_servers.server_public_ip}
    
    2. Prometheus Server:
       ssh -i ${path.module}/lab4-key ubuntu@${module.monitoring.prometheus_public_ip}
    
    3. Grafana Server:
       ssh -i ${path.module}/lab4-key ubuntu@${module.monitoring.grafana_public_ip}
    
    Web Access:
    - Main Server: http://${module.enhanced_servers.server_public_ip}
    - Prometheus: http://${module.monitoring.prometheus_public_ip}:9090
    - Grafana: http://${module.monitoring.grafana_public_ip}:3000 (admin/admin)
    
    =============================================================================
  EOT
}
