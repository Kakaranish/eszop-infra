variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "frontend_service_mig" {
  type = string
}

variable "frontend_service_healthcheck_id" {
  type = string
}

variable "gateway_service_mig" {
  type = string
}

variable "gateway_service_healthcheck_id" {
  type = string
}

variable "backend_svc_timeout_sec" {
  type    = number
  default = 30
}
