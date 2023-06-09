terraform {
  required_providers {
    grafana = {
      source  = "terraform-cache.dockstudios.co.uk/grafana/grafana"
      version = "1.40.1"
    }
  }
}

provider "grafana" {
  url  = "http://${var.grafana.endpoint}/"
  auth = "${var.grafana.admin_username}:${var.grafana.admin_password}"
}
