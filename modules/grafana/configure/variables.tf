variable "grafana" {
  description = "Grafana instance"
  type = object({
    endpoint       = string
    admin_username = string
    admin_password = string
  })
}

variable "loki" {
  description = "Loki instance"
  type = object({
    endpoint = string
  })
}

variable "victoria_metrics" {
  description = "Victoria Metrics instance"
  type = object({
    endpoint = string
  })
}
