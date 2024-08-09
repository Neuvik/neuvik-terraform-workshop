# Use a Data element to find the correct AMI for Ubuntu 20.04. This will be used in the resource.
# Use the Ubuntu 20.04 AMD64 Server AMI from the Canonical Account.check "name".
data "aws_ami" "ubuntu" { }

# Create a resource for the first instance, use the AMI from the data element.
# The instance Type to t3.nano
# Give it a name of c2_server
resource "aws_instance" "c2" { }

# Provide an EIP for the C2 Server
resource "aws_eip" "c2" { }
