# Use a Data element to find the correct AMI for Ubuntu 20.04. This will be used in the resource.
# Use the Ubuntu 20.04 AMD64 Server AMI from the Canonical Account.check "name".
data "aws_ami" "ubuntu" { }

# Create a resource for the first instance, use the AMI from the data element.
# The instance Type to t3.nano
# Give it a name of c2_server
# Don't forget to include user_data here which is going to be a data element.
resource "aws_instance" "c2" { }

# Provide an EIP for the C2 Server
resource "aws_eip" "c2" { }

# Create a file from a template to be used for userdata, specifically cloud-init
# This is the Template File that can be suitable for building c2.
# Note there are two variables listed here: 
# 
# hostname 
# users 
# 
# Hostname is going to come from c2_hostname
# Users is going to be a mapped list from users
#

resource "local_file" "cloud_init_c2_template" { }

# This will leverage teh dat afile above to create the cloud-init yaml file.
data "local_file" "cloud_init_c2_yaml" { }
