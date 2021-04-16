variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-central2"
}

variable "backend_image_name" {
  type = string
}

variable "frontend_image_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "environment_prefix" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

# ---  ENVIRONMENT VARIABLES  --------------------------------------------------

variable "ESZOP_LOGS_DIR" {
  type    = string
  default = "/logs"
}

variable "sql_server_db_username" {
  type      = string
  sensitive = true
}

variable "sql_server_db_password" {
  type      = string
  sensitive = true
}

variable "ESZOP_AZURE_EVENTBUS_CONN_STR" {
  type        = string
  description = "Azure ServiceBus connection string"
  sensitive   = true
}

variable "ESZOP_AZURE_STORAGE_CONN_STR" {
  type        = string
  description = "Azure Storage connection string"
  sensitive   = true
}

variable "ESZOP_REDIS_CONN_STR" {
  type        = string
  description = "Azure Redis Db connection string"
  sensitive   = true
}
