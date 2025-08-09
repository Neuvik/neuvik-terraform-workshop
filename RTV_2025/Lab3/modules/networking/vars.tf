variable "vpc_block" {
    description = "The CIDR Block for your VPN (10.0.0.0/16)"
    type = string
}
variable "vpcname" {
    description = "The VPC Name, this is a tag"
    type = string
}
variable "vpcdescription" {
    description = "The VPC Description, this is a tag"
    type = string
}

variable "public_subnet" {
    description = "The Public Subnet for example (10.0.0.0/24)"
    type = string
}

variable "region" {
    description = "The DataCenter you are in."
    type = string
}

variable "public_subnet_name" {
    description = "The Public Subnet Name, this is a tag"
    type = string
}

variable "public_subnet_description" {
    description = "The Public Subnet Description, this is a tag"
    type = string
}

variable "private_subnet" {
    type = string
}

variable "private_subnet_name" {
    type = string
}

variable "private_subnet_description" {
    type = string
}

variable "public_route_table_name" {
    type = string
}

variable "public_route_table_description" {
    type = string
}

variable "igw_name" {
    type = string
}

variable "igw_description" {
    type = string
}

variable "natgw_name" {
    type = string
}

variable "natgw_description" {
    type = string
}

variable "private_route_table_name" {
    type = string
}

variable "private_route_table_description" {
    type = string
}

variable "create_nat_gateway" {
    type    = bool
    default = false
}

variable "az" {
    type    = string
    default = "a"
}

variable "create_private_subnet" {
    type    = bool
    default = false
}