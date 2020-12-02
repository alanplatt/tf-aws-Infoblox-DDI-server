variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_pair" {
  type = string
  default = ""
}

variable "mgmt_subnet_id" {
  type = string
}

variable "management_ip" {
  type = string
}

variable "management_ip2" {
  type = string
}

variable "default_tags" {
  type = map
  default = {}
}

variable "name_prefix" {
  default = ""
}

variable "admin_password" {
  default = ""
}

variable "remote_console_enabled" {
  default = "y"
}

variable "temp_license" {
  default = "cloud vnios dns grid"
}

variable "include_public_ip" {
  default = false
}