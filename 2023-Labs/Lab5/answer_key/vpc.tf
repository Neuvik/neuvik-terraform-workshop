# This is required to exposed things behind a NAT
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# Remember to use the VPC from the pervious exercise.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Remember to use the Subnet from the pervious exercise.
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

# Create an Internet Gateway, and attach it to the VPC.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Any resources that are not needing to be on the internet but do need to access the internet need the system below.
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.main.id
}

# This is the routing table for the public subnet, this builds the objects and the routes are added to this table.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

# This is the route table for the public subnet, only a generic 0/0 route is needed.
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

#This associates the route table to the subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}