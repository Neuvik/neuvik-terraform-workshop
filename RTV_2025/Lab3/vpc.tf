module "vpc_network" {
  source = "./modules/networking"

  vpc_block                       = var.cidr_block_east                 # Supernet containing all subnets, default = "10.0.0.0/16"
  vpcname                         = var.vpc_name                        # VPC name
  vpcdescription                  = var.vpc_description                 # Description tag
  public_subnet                   = var.public_subnet                   # Public subnet range, default = "10.0.0.0/24"
  public_subnet_name              = var.public_subnet_name              # Public subnet name, default = "public-subnet"
  public_subnet_description       = var.public_subnet_description       # Public subnet description
  region                          = var.region                          # AWS region, default = us-east-1
  private_subnet                  = var.private_subnet                  # Private subnet range, default = "10.0.1.0/24"
  private_subnet_name             = var.private_subnet_name             # Private subnet name, default = "private-subnet"
  private_subnet_description      = var.private_subnet_description      # Private subnet description
  public_route_table_name         = var.public_route_table_name         # Route table name, default = "public-route-table"
  public_route_table_description  = var.public_route_table_description  # Route table description
  igw_name                        = var.igw_name                        # Internet Gateway name, default = "internet-gateway"
  igw_description                 = var.igw_description                 # Internet Gateway description
  natgw_name                      = var.natgw_name                      # NAT Gateway name, default = "nat-gateway"
  natgw_description               = var.natgw_description               # NAT Gateway description
  private_route_table_name        = var.private_route_table_name        # Private route table name
  private_route_table_description = var.private_route_table_description # Private route table description
  create_nat_gateway              = var.create_nat_gateway              # Create NAT gateway for private subnets
  az                              = var.az                              # Availability zone, default = "a"
}