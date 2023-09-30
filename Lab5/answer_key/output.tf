output "c2_public_ip" {
  description = "The IP of the C2 Server"
  value       = module.c2_server.c2_public_ip
}

output "c2_private_ip" {
  description = "The IP of the C2 Server"
  value       = module.c2_server.c2_private_ip
}

### Can we make it prettier?

output "final_text" {
  value = <<EOF
-------------------------------------------------------------------------------

Outputing Server Information:

C2 Server Private IP:         ${try(module.c2_server.c2_private_ip, null)}
C2 Server Public IP:          ${try(module.c2_server.c2_public_ip, null)}
Redirector Server Private IP: ${try(module.redirector_server.c2_private_ip, null)}
Redirector Server Public IP:  ${try(module.redirector_server.c2_public_ip, null)}

-------------------------------------------------------------------------------
EOF
}