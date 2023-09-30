# Use a Data element to find the correct AMI for Ubuntu 20.04. This will be used in the resource.
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
resource "aws_instance" "c2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.nano"

  tags = {
    Name = "c2_server"
  }
}
