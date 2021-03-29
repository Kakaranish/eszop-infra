variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "db_name" {
  type = string
}

variable "sql_sa_login" {
  type = string
}

variable "sql_sa_password" {
  type      = string
  sensitive = true
}

variable "allowed_ip" {
  type = string
}

variable "backups_container_uri" {
  type = string
}

variable "storage_key" {
  type = string
}

variable "service_name" {
  type = string
}

variable "import_suffix" {
  type = string
}

variable "environment" {
  type = string
}