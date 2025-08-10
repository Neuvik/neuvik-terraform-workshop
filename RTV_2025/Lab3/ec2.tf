module "sliver_c2" {
  source = "./modules/servers"

  subnet_id              = module.vpc_network.public_subnet_id
  network_interface_ip   = var.sliver_c2_ip
  network_interface_name = var.sliver_c2_nic_name
  security_group_id      = aws_security_group.main_sg.id
  ami_id                 = data.aws_ami.ubuntu.id
  operators              = var.operators
  instance_type          = "t3.small"
  root_block_size        = 100
  server_name            = "SLIVER-C2"
  prevent_destroy        = false
  user_data              = true
  assessment             = "RedTeamVillage"
  commands               = var.sliver_commands
}   

module "bastion" {
  source = "./modules/servers"

  subnet_id              = module.vpc_network.public_subnet_id
  network_interface_ip   = var.bastion_ip
  network_interface_name = var.bastion_nic_name
  security_group_id      = aws_security_group.main_sg.id
  ami_id                 = data.aws_ami.ubuntu.id
  operators              = var.operators
  instance_type          = "t3.small"
  root_block_size        = 100
  server_name            = "SSH-BASTION"
  prevent_destroy        = false
  user_data              = true
  assessment             = "RedTeamVillage"
  commands               = var.bastion_commands
}