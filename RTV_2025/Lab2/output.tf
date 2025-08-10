output "final_text" {
    value = <<EOF
  -------------------------------------------------------------------------------
  Bastion Private IP:            ${try(aws_instance.bastion.private_ip, null)}
  Bastion Public IP:             ${try(aws_instance.bastion.public_ip, null)}
  -------------------------------------------------------------------------------
  EOF
  }