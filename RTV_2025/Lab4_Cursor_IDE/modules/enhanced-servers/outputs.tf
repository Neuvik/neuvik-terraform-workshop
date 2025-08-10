output "server_public_ip" {
  description = "Public IP of the server"
  value       = aws_instance.server.public_ip
}

output "server_private_ip" {
  description = "Private IP of the server"
  value       = aws_instance.server.private_ip
}

output "server_security_group_id" {
  description = "ID of the server security group"
  value       = aws_security_group.server.id
}
