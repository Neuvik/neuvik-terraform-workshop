# Create a VPC, use 10.0.0.0/8 as the main resource for the PVPC
resource "aws_vpc" "main" { }

# Create a subnet for resources.
resource "aws_subnet" "main" { }

# Create an aws_eip resource that includes the VPC, this will be for the nat gateway.
resource "aws_eip" "nat_eip" { }

# Create an Internet Gateway, and attach it to the VPC.
resource "aws_internet_gateway" "gw" { }

# Create a NAT Gateway, and attach it to the subnet.
resource "aws_nat_gateway" "nat" { }

# Create a routing table for the public subnet.
resource "aws_route_table" "public" { }

# Add a route for the default subnet of 0.0.0.0 and attach it to the routing table
resource "aws_route" "public" { }

# Associate the routing table to the subnet
resource "aws_route_table_association" "public" { }
