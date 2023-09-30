# Use a Data element to find the correct AMI for Ubuntu 20.04. This will be used in the resource.
# Use the Ubuntu 20.04 AMD64 Server AMI from the Canonical Account.check "name".
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

# Create a resource for the first instance, use the AMI from the data element.
# The instance Type to t3.nano
# Give it a name of c2_server
resource "aws_instance" "c2" {
  ami           = data.aws_ami.ubuntu.id # This is the ID number of the Data element generated above
  instance_type = "t3.nano" # This is a small instance type

  subnet_id = aws_subnet.main.id # This is the aws subnet ID for the public subnet, meant to be a DMZ this is how a "Public IP" is attached to an instance.

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