variable "users_list" {
  description = "In here you need to use your own SSH private key, this is just an example."
  type        = map(any)

  default = {
    "moses" = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPyOdTJ3mXw4X0XRSGxlrllvUw1chX4uk1FPerUcJtEo+RSKR1OIRFoXwohk3D+7jfY+6FS6qd+QfKYWg0A7HqU= moses",
  }
}

variable "c2_hostname" {
  description = "This is a list that is fed to build local users in the VMs. This uses the username / ssh key pairing to fill out the cloud-init templates"
  type        = string
  default     = "c2server"
}
