variable "resource_group" {
  type    = string
  default = "eSzop"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "subscription_id" {
  type = string
}

variable "allowed_ip" {
  type = string
}

variable "sql_sa_login" {
  type = string
}

variable "sql_sa_password" {
  type      = string
  sensitive = true
}