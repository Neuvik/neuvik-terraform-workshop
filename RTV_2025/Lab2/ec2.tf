resource "local_file" "cloud_init_ubuntu" {
  content = templatefile("${path.module}/ec2.tmpl", {
    hostname = "bastion",
    users    = var.operators
  })
  filename = "./ec2.yaml"
}

data "local_file" "cloud_init_ubuntu" {
  filename = local_file.cloud_init_ubuntu.filename
  depends_on = [
    local_file.cloud_init_ubuntu
  ]
}

resource "aws_instance" "bastion" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t3.small"
  subnet_id         = aws_subnet.main.id # This is the aws subnet ID for the public subnet, meant to be a DMZ this is how a "Public IP" is attached to an instance.
  source_dest_check = false

  vpc_security_group_ids = [
    aws_security_group.main_sg.id # Default security group
  ]

  user_data = data.local_file.cloud_init_ubuntu.content

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "required"
  }

  tags = {
    Name = "Bastion Host"
  }

  lifecycle {
    #ignore_changes = [
    #  ami,       # Do not remove this, any changes to the Ubuntu AMI will cause this repo to redeploy the machine
    #  user_data, # Do not remove this, any changes to the User Data will cause this machine to be rebuilt!
    #]
    #prevent_destroy = true
  }
}
