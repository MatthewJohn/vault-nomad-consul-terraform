locals {
  config_files = {
    
      "scrape.yml" = <<EOF
scrape_configs:

# - job_name: dns
#   dns_sd_configs:
#     # names must contain a list of DNS names to query.
#   - names: ["...", "..."]

- job_name: consul
  metrics_path: '/v1/agent/metrics?format=prometheus'
  consul_sd_configs:
  - server: "${module.consul_client.listen_host}:${module.consul_client.port}"
    token: "${data.consul_acl_token_secret_id.victoria_metrics.secret_id}"
    datacenter: "${var.consul_datacenter.name}"
    scheme: "https"

    services: ["consul-ui"]

    # TLS config for connecting to consul for service discovery
    tls_config:
      ca_file: /consul/config/client-certs/ca.crt

  # TLS config for connecting to targets
  tls_config:
    ca_file: /consul/config/client-certs/ca.crt

  # Force use of https for getting metrics
  relabel_configs:
    - source_labels: [__meta_consul_service]
      #regex: (SERVICE_NAME1|SERVICE_NAME2)
      target_label: __scheme__
      replacement: https

EOF
  }
}

resource "null_resource" "config" {

  for_each = local.config_files

  triggers = {
    config = each.value
  }

  connection {
    type = "ssh"
    user = var.docker_username
    host = var.docker_host
  }

  provisioner "file" {
    content     = each.value
    destination = "/victoria-metrics/config/${each.key}"
  }
}
