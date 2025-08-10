# =============================================================================
# MONITORING MODULE OUTPUTS
# =============================================================================
# Outputs for the monitoring module resources

output "prometheus_public_ip" {
  description = "Public IP address of the Prometheus server"
  value       = aws_instance.prometheus.public_ip
}

output "prometheus_private_ip" {
  description = "Private IP address of the Prometheus server"
  value       = aws_instance.prometheus.private_ip
}

output "grafana_public_ip" {
  description = "Public IP address of the Grafana server"
  value       = aws_instance.grafana.public_ip
}

output "grafana_private_ip" {
  description = "Private IP address of the Grafana server"
  value       = aws_instance.grafana.private_ip
}

output "monitoring_security_group_id" {
  description = "ID of the monitoring security group"
  value       = aws_security_group.monitoring.id
}
