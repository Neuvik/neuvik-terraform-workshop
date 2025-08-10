variable "region" {
  type        = string
  description = "This is the region we are working with"
}

variable "operators" {
  description = "This is a list that is fed to build local users in the VMs. This uses the username / ssh key pairing to fill out the cloud-init templates"
  type        = map(any)
  default = {
    "operator" = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMppIbnbcqOu8CsBK1VhFlZCCJbPch5qyQjGFa1CQmqSAAAABHNzaDo="
  }
}