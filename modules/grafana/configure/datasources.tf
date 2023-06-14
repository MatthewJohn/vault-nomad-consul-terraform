resource "grafana_data_source" "loki" {
  type               = "loki"
  name               = "Loki"
  url                = "http://${var.loki.endpoint}"
  basic_auth_enabled = false
  access_mode        = "proxy"
}

resource "grafana_data_source" "victoria_metrics" {
  type               = "prometheus"
  name               = "VictoriaMetrics"
  url                = "http://${var.victoria_metrics.endpoint}"
  basic_auth_enabled = false
  access_mode        = "proxy"
}
