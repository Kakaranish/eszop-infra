variable "sql_sa_login" {
  type = string
}

variable "sql_sa_password" {
  type = string
  sensitive = true
}

variable "subscription_id" {
  type = string
  sensitive = true
}