variable "subscription_id" {
  type = string
}

variable "global_resource_group" {
  type    = string
  default = "eszop"
}

variable "global_storage_name" {
  type = string
}

variable "location" {
  type    = string
  default = "Germany West Central"
}

variable "env_prefix" {
  type = string
}
