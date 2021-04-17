variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "sql_sa_login" {
  type = string
}

variable "sql_sa_password" {
  type      = string
  sensitive = true
}

variable "server_name" {
  type = string
}

variable "allowed_ip" {
  type = string
}