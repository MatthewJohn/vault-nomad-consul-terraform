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
  scrape_interval: 10s
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
  bearer_token: "${data.consul_acl_token_secret_id.victoria_metrics.secret_id}"

  # Force use of https for getting metrics
  relabel_configs:
    - source_labels: [__meta_consul_service]
      #regex: (SERVICE_NAME1|SERVICE_NAME2)
      target_label: __scheme__
      replacement: https
    - source_labels: [__meta_consul_node]
      target_label: consul_node

- job_name: nomad
  metrics_path: '/v1/metrics'
  params:
    format: ['prometheus']
  scrape_interval: 10s
  consul_sd_configs:
  - server: "${module.consul_client.listen_host}:${module.consul_client.port}"
    token: "${data.consul_acl_token_secret_id.victoria_metrics.secret_id}"
    datacenter: "${var.consul_datacenter.name}"
    scheme: "https"

    services: ["nomad"]
    filter: "\"http\" in ServiceTags"

    # TLS config for connecting to consul for service discovery
    tls_config:
      ca_file: /consul/config/client-certs/ca.crt

  # Skip TLS verification for noamd cert
  # @TODO Provide CA certificate for verification
  tls_config:
    insecure_skip_verify: true

  # Force use of https for getting metrics
  relabel_configs:
    - source_labels: [__meta_consul_service]
      #regex: (SERVICE_NAME1|SERVICE_NAME2)
      target_label: __scheme__
      replacement: https
    # Only keep http tagged instances
    - source_labels: ['__meta_consul_tags']
      regex: '^.*,http,.*$'
      action: keep
    - source_labels: [__meta_consul_node]
      target_label: consul_node

- job_name: nomad-client
  metrics_path: '/v1/metrics'
  params:
    format: ['prometheus']
  scrape_interval: 10s
  consul_sd_configs:
  - server: "${module.consul_client.listen_host}:${module.consul_client.port}"
    token: "${data.consul_acl_token_secret_id.victoria_metrics.secret_id}"
    datacenter: "${var.consul_datacenter.name}"
    scheme: "https"

    services: ["nomad-global-client"]
    filter: "\"http\" in ServiceTags"

    # TLS config for connecting to consul for service discovery
    tls_config:
      ca_file: /consul/config/client-certs/ca.crt

  # Skip TLS verification for noamd cert
  # @TODO Provide CA certificate for verification
  tls_config:
    insecure_skip_verify: true

  # Force use of https for getting metrics
  relabel_configs:
    - source_labels: [__meta_consul_service]
      #regex: (SERVICE_NAME1|SERVICE_NAME2)
      target_label: __scheme__
      replacement: https
    - source_labels: [__meta_consul_node]
      target_label: consul_node

- job_name: 'vault'
  metrics_path: "/v1/sys/metrics?format=prometheus"
  scrape_interval: 10s
  # Allow redirect to primary
  stream_parse: true
  follow_redirects: true
  # params:
  #   format: ['prometheus']
  scheme: https
  tls_config:
    ca_file: "/victoria-metrics-config/vault_ca_cert.pem"
  authorization:
    credentials_file: "${module.vault_agent.token_path}"
  static_configs:
  - targets: ['${var.vault_cluster.address}']

- job_name: consul-connect-envoy
  scrape_interval: 10s
  consul_sd_configs:
  - server: "${module.consul_client.listen_host}:${module.consul_client.port}"
    token: "${data.consul_acl_token_secret_id.victoria_metrics.secret_id}"
    datacenter: "${var.consul_datacenter.name}"
    scheme: "https"
    # TLS config for connecting to consul for service discovery
    tls_config:
      ca_file: /consul/config/client-certs/ca.crt
  relabel_configs:
    - source_labels: [__meta_consul_service]
      regex: (.+)-sidecar-proxy
      action: drop
    - source_labels: [__meta_consul_service_metadata_metrics_port_envoy]
      regex: (.+)
      action: keep
    - source_labels: [__address__,__meta_consul_service_metadata_metrics_port_envoy]
      regex: ([^:]+)(?::\d+)?;(\d+)
      replacement: $${1}:$${2}
      target_label: __address__
    - source_labels: [__meta_consul_node]
      target_label: consul_node

- job_name: node-exporter
  scrape_interval: 10s
  consul_sd_configs:
  - server: "${module.consul_client.listen_host}:${module.consul_client.port}"
    token: "${data.consul_acl_token_secret_id.victoria_metrics.secret_id}"
    datacenter: "${var.consul_datacenter.name}"
    scheme: "https"
    services: ["node_exporter"]
    # TLS config for connecting to consul for service discovery
    tls_config:
      ca_file: /consul/config/client-certs/ca.crt

  relabel_configs:
    - source_labels: [__meta_consul_node]
      target_label: consul_node

- job_name: traefik
  scrape_interval: 10s
  consul_sd_configs:
  - server: "${module.consul_client.listen_host}:${module.consul_client.port}"
    token: "${data.consul_acl_token_secret_id.victoria_metrics.secret_id}"
    datacenter: "${var.consul_datacenter.name}"
    scheme: "https"
    services: ["traefik-http-metrics"]
    # TLS config for connecting to consul for service discovery
    tls_config:
      ca_file: /consul/config/client-certs/ca.crt

  relabel_configs:
    - source_labels: [__meta_consul_node]
      target_label: consul_node

EOF

    "vault_ca_cert.pem" = file(var.vault_cluster.ca_cert_file)
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
