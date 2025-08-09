resource "local_file" "cloud_init_ubuntu" {
      content = templatefile("${path.module}/templates/ec2.tmpl", {
        hostname = var.server_name,
        users    = var.operators,
        commands = var.commands
      })
      filename = "${path.module}/files/ec2.yaml"
    }

    data "local_file" "cloud_init_ubuntu" {
      filename = local_file.cloud_init_ubuntu.filename
      depends_on = [
        local_file.cloud_init_ubuntu
      ]
    }

resource "aws_network_interface" "this" {
  subnet_id = var.subnet_id
  private_ips = [
    var.network_interface_ip
  ]

  tags = {
    Name = var.network_interface_name
  }
}

resource "aws_network_interface_sg_attachment" "this" {
  security_group_id    = var.security_group_id
  network_interface_id = aws_network_interface.this.id
}

# Standard Generic Server
resource "aws_instance" "this" {
  ami               = var.ami_id
  instance_type     = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.this.id
    device_index         = 0
  }

  #user_data                   = var.user_data

  root_block_device {
    volume_size           = var.root_block_size
    delete_on_termination = var.delete_on_termination
    tags = {
      "Name" = var.root_disk_name
    }
  }

  user_data = var.user_data == false ? null : data.local_file.cloud_init_ubuntu.content

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "required"
  }

  tags = {
    Name = var.server_name
    Assessment = var.assessment
  }
}

