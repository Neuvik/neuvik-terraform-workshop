resource "aws_vpc" "this" {
  cidr_block           = var.vpc_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = var.vpcname
    Description = var.vpcdescription
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet
  availability_zone = "${var.region}${var.az}"
  map_public_ip_on_launch = true

  tags = {
    Name        = var.public_subnet_name
    Description = var.public_subnet_description
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name        = var.public_route_table_name
    Description = var.public_route_table_description
  }
}

#This associates the route table to the subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = var.igw_name
    Description = var.igw_description
  }
}

# This is required to exposed things behind a NAT
resource "aws_eip" "nat_eip" {
  count = var.create_nat_gateway ? 1 : 0
  domain = "vpc"
  depends_on = [
    aws_internet_gateway.this
  ]
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name        = var.natgw_name
    Description = var.natgw_description
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.create_private_subnet ? 1 : 0
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet
  availability_zone = "${var.region}${var.az}"

  tags = {
    Name        = var.private_subnet_name
    Description = var.private_subnet_description
  }
}

#This associates the route table to the subnet
resource "aws_route_table_association" "private" {
  count          = var.create_private_subnet ? 1 : 0
  subnet_id      = aws_subnet.private_subnet[0].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table" "private" {
  count  = var.create_private_subnet ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = {
    Name        = var.private_route_table_name
    Description = var.private_route_table_description
  }
}

resource "aws_route" "private" {
    count                  = var.create_nat_gateway ? 1 : 0
    route_table_id         = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.this[0].id
}