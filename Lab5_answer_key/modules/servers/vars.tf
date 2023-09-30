variable "server_name" { 
  description = "The Server Name"
  type = string
  default = ""
}

variable "main_subnet" { 
    description = "The subnet for this server"
    type = string
    default = ""
}

variable "security_group_id" { 
    description = "The security group for this server"
    type = string
    default = ""
}

variable user_data {
  type        = list
  description = "This is the userdata for ther server"
  default     = [""]
}

variable "users_list" { 
  type = map(any)
  description = "A list of users."
  default = { "" = "" }
}

variable "cloud_init_yaml_name" {
  type = string
  description = "What would you like to name this yaml file?"
}

