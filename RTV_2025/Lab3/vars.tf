# AWS Region selection
variable "region" {
  type        = string
  description = "AWS region to deploy resources (e.g., us-east-1)"
}

# VPC Configuration
variable "cidr_block_east" {
  type        = string
  description = "Supernet block for AWS VPC"
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

# Public Subnet Configuration
variable "public_subnet" {
  type        = string
  description = "Public Subnet CIDR"
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

# Private Subnet Configuration
variable "private_subnet" {
  type        = string
  description = "Private Subnet CIDR"
  default     = "10.0.1.0/24"
}

variable "private_subnet_name" {
  type        = string
  description = "Private Subnet Name"
  default     = "private-subnet"
}

variable "private_subnet_description" {
  type        = string
  description = "Private Subnet Description"
  default     = "Private Subnet"
}

# Route Table Configuration
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

variable "private_route_table_name" {
  type        = string
  description = "Private Route Table Name"
  default     = "private-route-table"
}

variable "private_route_table_description" {
  type        = string
  description = "Private Route Table Description"
  default     = "Private Route Table"
}

# Gateway Configuration
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
  description = "NAT Gateway Description"
  default     = "NAT Gateway"
}

# Additional Configuration
variable "create_nat_gateway" {
  type        = bool
  description = "Create NAT Gateway for private subnets"
  default     = false
}

variable "az" {
  type        = string
  description = "Availability Zone"
  default     = "a"
}

# Sliver C2 Server Configuration
variable "sliver_c2_ip" {
  type    = string
  default = "10.0.0.20"
}

variable "sliver_c2_nic_name" {
  type    = string
  default = "SLIVER-C2-NIC0"
}

variable "operators" {
  type = map(any)
  default = {
    "operator"  = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMppIbnbcqOu8CsBK1VhFlZCCJbPch5qyQjGFa1CQmqSAAAABHNzaDo="
  }
}

variable "sliver_commands" {
  type = map(any)
  default = {
    command_one   = "curl https://sliver.sh/install|sudo bash",
    command_two   = "systemctl daemon-reload",
    command_three = "systemctl enable sliver"
  }
}

# Bastion Host Configuration
variable "bastion_ip" {
  type    = string
  default = "10.0.0.21"
}

variable "bastion_nic_name" {
  type    = string
  default = "BASTION-NIC0"
}

variable "bastion_commands" {
  type = map(any)
  default = {
    command_one = "hostnamectl set-hostname bastion"
  }
}