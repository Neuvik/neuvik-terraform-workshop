# Use a Data element to find the correct AMI for Ubuntu 20.04. This will be used in the resource.
# Use the Ubuntu 20.04 AMD64 Server AMI from the Canonical Account.check "name".
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create a file from a template to be used for userdata, specifically cloud-init
# This is the Template File that can be suitable for building c2.
resource "local_file" "cloud_init_c2_template" {
  content = templatefile("${path.module}/templates/cloud-init-c2.tmpl", {
    users    = var.users_list
    hostname = var.c2_hostname
  })

  filename = "${path.module}/files/cloud-init-c2.yaml"
}

data "local_file" "cloud_init_c2_yaml" {
  filename   = local_file.cloud_init_c2_template.filename
  depends_on = [local_file.cloud_init_c2_template]
}

# Create a resource for the first instance, use the AMI from the data element.
# The instance Type to t3.nano
# Give it a name of c2_server
resource "aws_instance" "c2" {
  ami           = data.aws_ami.ubuntu.id # This is the ID number of the Data element generated above
  instance_type = "t3.micro"             # This is a small instance type

  subnet_id = aws_subnet.main.id # This is the aws subnet ID for the public subnet, meant to be a DMZ this is how a "Public IP" is attached to an instance.
  user_data = data.local_file.cloud_init_c2_yaml.content

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]

  root_block_device {
    volume_size = 40 # This a 40GB instance size, it can be larger
  }

  tags = {
    Name = "c2_server"
  }
}

resource "aws_eip" "c2" {
  instance = aws_instance.c2.id
  domain   = "vpc"
}
