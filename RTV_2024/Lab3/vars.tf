#The variable below allows you to chose an AWS DataCenter such as "us-east-1"
variable "region" {
  type        = string
  description = "Please what Datacenter you wish to use, such as us-east-1"
}

variable "cidr_block_east" {
  type        = string
  description = "Supernet Block for AWS"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name"
  default     = "main-vpc"
}

variable "vpc_description" {
  type        = string
  description = "VPC Description"
  default     = "Main VPC"
}

variable "public_subnet" {
  type        = string
  description = "Public Subnet"
  default     = "10.0.0.0/24"
}

variable "public_subnet_name" {
  type        = string
  description = "Public Subnet Name"
  default     = "public-subnet"
}

variable "public_subnet_description" {
  type        = string
  description = "Public Subnet Description"
  default     = "Public Subnet"
}

variable "private_subnet" {
  type        = string
  description = "Public Subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_name" {
  type        = string
  description = "Private Subnet Name"
  default     = "private-subnet"
}

variable "private_subnet_description" {
  type        = string
  description = "Public Subnet Description"
  default     = "public-subnet"
}

variable "public_route_table_name" {
  type        = string
  description = "Public Route Table Name"
  default     = "public-route-table"
}

variable "public_route_table_description" {
  type        = string
  description = "Public Route Table Description"
  default     = "Public Route Table"
}

variable "igw_name" {
  type        = string
  description = "Internet Gateway Name"
  default     = "internet-gateway"
}

variable "igw_description" {
  type        = string
  description = "Internet Gateway Description"
  default     = "Internet Gateway"
}

variable "natgw_name" {
  type        = string
  description = "NAT Gateway Name"
  default     = "nat-gateway"

}

variable "natgw_description" {
  type        = string
  description = "Internet Gateway Description"
  default     = "Internet Gateway"
}

variable "private_route_table_name" {
  type        = string
  description = "private Route Table Name"
  default     = "private-route-table"
}

variable "private_route_table_description" {
  type        = string
  description = "private Route Table Description"
  default     = "Private Route Table"
}

variable "create_nat_gateway" {
  type        = bool
  description = "Create NAT Gateway"
  default     = false
}

variable "az" {
  type        = string
  description = "What Availability Zone"
  default     = "a"
}
