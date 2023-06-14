resource "grafana_folder" "vcn" {
  title = "Vault/Consul/Nomad"
}

locals {
  dashboards = ["nomad_cluster", "vault", "nomad_jobs", "consul_mesh", "node_exporter_per_host"]
}

data "template_file" "dashboard" {
  for_each = toset(local.dashboards)

  template = file("${path.module}/dashboards/${each.value}.json")
  vars = {
    victoria_metrics_datasource_id = grafana_data_source.victoria_metrics.id
    loki_datasource_id             = grafana_data_source.loki.id
  }
}

resource "grafana_dashboard" "this" {
  for_each = toset(local.dashboards)

  folder      = grafana_folder.vcn.id
  config_json = data.template_file.dashboard[each.key].rendered
  overwrite   = true
}
