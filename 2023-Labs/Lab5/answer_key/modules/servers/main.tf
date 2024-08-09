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

resource "local_file" "cloud_init_template" {
  content = templatefile("${path.module}/templates/cloud-init.tmpl", {
    users    = var.users_list
    hostname = var.server_name
  })

  filename = "${path.module}/files/${var.cloud_init_yaml_name}"
  #filename = "${path.module}/files/cloud-init.yaml"
}

# Create a resource for the first instance, use the AMI from the data element.
# The instance Type to t3.nano
# Give it a name of c2_server
resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id # This is the ID number of the Data element generated above
  instance_type = "t3.micro"             # This is a small instance type

  subnet_id = var.main_subnet # This is a variable that is fed into the module
  user_data = local_file.cloud_init_template.content

  vpc_security_group_ids = [
    var.security_group_id
  ]

  root_block_device {
    volume_size = 40 # This a 40GB instance size, it can be larger
  }

  tags = {
    Name = var.server_name
  }
}

resource "aws_eip" "server" {
  instance = aws_instance.server.id
  domain   = "vpc"
}
