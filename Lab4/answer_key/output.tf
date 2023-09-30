output "c2_public_ip" {
  value = aws_eip.c2.public_ip
}

output "c2_private_ip" {
  value = aws_instance.c2.private_ip
}