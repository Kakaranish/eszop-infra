variable "project_id" {
  type = string
}

variable "global_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "image_name" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "service_name" {
  type = string
}

variable "metadata" {
  type = map(any)
}

variable "healthcheck_path" {
  type    = string
  default = "/healthcheck"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 3
}
