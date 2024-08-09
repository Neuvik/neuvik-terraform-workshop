module "vpc_network" {
  source = "../modules/networking"

  vpc_block                       = var.cidr_block_east                 # This is the Supernet that contains all your subnet, default = "10.0.0.0/16"
  vpcname                         = var.vpc_name                        # This is the name of the VPC
  vpcdescription                  = var.vpc_description                 # This is a description tag for it
  public_subnet                   = var.public_subnet                   # This is the public subnet range which the default = "10.0.0.0/24"
  public_subnet_name              = var.public_subnet_name              # This is the public subnet name, default is "public-subnet"
  public_subnet_description       = var.public_subnet_description       # This is the public subnet description, default is "public subnet"
  region                          = var.region                          # This is the region, default is us-east-1, like the rest of the world.
  private_subnet                  = var.private_subnet                  # This is the private subnet range, which the default is = "10.0.1.0/24"
  private_subnet_name             = var.private_subnet_name             # This is the private subnet name, default is "private-subnet"
  private_subnet_description      = var.private_subnet_description      # This is the private subnet description, the default is private subnet
  public_route_table_name         = var.public_route_table_name         # This is the name of the Route Table, default is "public-route-table"
  public_route_table_description  = var.public_route_table_description  # This is the description of the Route Table, default is "Public Route Table"
  igw_name                        = var.igw_name                        # This is the name of the Internet Gateway, default is "internet-gateway"
  igw_description                 = var.igw_description                 # This is the description of the Internet Gateway, default is "Internet Gateway"
  natgw_name                      = var.natgw_name                      # This is the name of the Internet Gateway, default is "nat-gateway"
  natgw_description               = var.natgw_description               #This is the description of the Internet Gateway, default is "NAT Gateway"
  private_route_table_name        = var.private_route_table_name        # This is the name of the Route Table, default is "private-route-table"
  private_route_table_description = var.private_route_table_description # This is the description of the Route Table, default is "Private Route Table"
  create_nat_gateway              = var.create_nat_gateway              # This instructs the system to create a NAT gateway for private subnets
  az                              = var.az                              # Availability zone such as "a" for each datacenter, default is "a"
}