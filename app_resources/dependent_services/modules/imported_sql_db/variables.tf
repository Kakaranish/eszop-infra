variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "server_name" {
  type = string
}

variable "service_name" {
  type = string
}

# ---  Import variables  -------------------------------------------------------

variable "sql_sa_login" {
  type = string
}

variable "sql_sa_password" {
  type      = string
  sensitive = true
}

variable "backups_container_uri" {
  type = string
}

variable "storage_key" {
  type = string
}

variable "import_suffix" {
  type = string
}