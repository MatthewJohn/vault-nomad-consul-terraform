resource "grafana_folder" "vcn" {
  title = "Vault/Consul/Nomad"
}

data "template_file" "nomad_cluster_dashboard" {
  template = file("${path.module}/dashboards/nomad_cluster.json")
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

data "template_file" "vault_dashboard" {
  template = file("${path.module}/dashboards/vault.json")
  vars = {
    victoria_metrics_datasource_id = grafana_data_source.victoria_metrics.id
  }
}

resource "grafana_dashboard" "vault_dashboard" {
  folder      = grafana_folder.vcn.id
  config_json = data.template_file.vault_dashboard.rendered
  overwrite   = true
}

data "template_file" "nomad_jobs_dashboard" {
  template = file("${path.module}/dashboards/nomad_jobs.json")
  vars = {
    victoria_metrics_datasource_id = grafana_data_source.victoria_metrics.id
  }
}

resource "grafana_dashboard" "nomad_jobs" {
  folder      = grafana_folder.vcn.id
  config_json = data.template_file.nomad_jobs_dashboard.rendered
  overwrite   = true
}