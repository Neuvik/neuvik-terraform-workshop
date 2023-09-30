data "aws_availability_zones" "available" {
  state = "available"
}

# Create a resource for the first instance, use the AMI from the data element.
# The instance Type to t3.nano
# Give it a name of c2_server
module "c2_server" {
  source = "./modules/servers"

  server_name          = local.c2_server_name
  main_subnet          = aws_subnet.main.id
  security_group_id    = aws_security_group.default.id
  cloud_init_yaml_name = local.c2_cloud_init_yaml_name
  users_list           = var.users_list
}

module "redirector_server" {
  source = "./modules/servers"

  server_name          = local.redirector_server_name
  main_subnet          = aws_subnet.main.id
  security_group_id    = aws_security_group.default.id
  cloud_init_yaml_name = local.redirector_cloud_init_yaml_name
  users_list           = var.users_list
}