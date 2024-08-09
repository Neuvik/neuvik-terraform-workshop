variable "network_interface_ip" {
    type = string
}

variable "network_interface_name" {
    type = string
}

variable "security_group_id" {
    type = string
}

variable "ami_id" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "root_block_size" {
    type = number
}

variable "server_name" {
    type = string
}

variable "prevent_destroy" {
    type = bool
}

variable "subnet_id" {
    type = string
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set"
  type        = bool
  default     = null
}

variable "environment" {
    type    = string
    default = "Production"
}

variable "root_disk_name" {
    type    = string
    default = ""
}

variable "delete_on_termination" {
    type    = string
    default = "true"
}

variable "operators" {
    type = map(any)
}

variable "assessment" {
    type = string
}

variable "commands" {
    type = map(any)
}