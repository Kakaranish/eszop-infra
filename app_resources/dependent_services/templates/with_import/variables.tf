variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "Germany West Central"
}

variable "environment" {
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

variable "import_suffix" {
  type      = string
}