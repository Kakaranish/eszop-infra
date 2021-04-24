variable "project_id" {
  type = string
}

variable "global_project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-central2"
}

variable "image_name" {
  type = string
}

variable "redis_password" {
  type      = string
  sensitive = true
}

variable "redis_address_res_name" {
  type = string
}

variable "environment" {
  type = string
}
