variable "project_id" {
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

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "healthcheck_path" {
  type = string
  default = "/healthcheck"
}
