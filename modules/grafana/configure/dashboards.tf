resource "grafana_folder" "vcn" {
  title = "Vault/Consul/Nomad"
}

data "template_file" "nomad_cluster_dashboard" {
  template = "${file("${path.module}/dashboards/nomad_cluster.tpl")}"
  vars = {
    victoria_metrics_datasource_id = grafana_data_source.victoria_metrics.id
    loki_datasource_id             = grafana_data_source.loki.id
  }
}

resource "grafana_dashboard" "nomad_dashboard" {
  folder      = grafana_folder.vcn.id
  config_json = data.template_file.nomad_cluster_dashboard.rendered
  overwrite   = true
}