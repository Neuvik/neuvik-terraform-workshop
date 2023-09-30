output "c2_public_ip" {
  value = aws_eip.server.public_ip
}

output "c2_private_ip" {
  value = aws_instance.server.private_ip
}
