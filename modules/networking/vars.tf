variable "vpc_block" {
    type = string
}
variable "vpcname" {
    type = string
}
variable "vpcdescription" {
    type = string
}

variable "public_subnet" {
    type = string
}

variable "region" {
    type = string
}

variable "public_subnet_name" {
    type = string
}

variable "public_subnet_description" {
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
    default = true
}

variable "az" {
    type    = string
    default = "a"
}