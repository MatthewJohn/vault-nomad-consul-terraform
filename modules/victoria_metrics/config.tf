locals {
  config_files = {
    
      "scrape.yml" = <<EOF
scrape_configs:
- job_name: consulagent
  consul_sd_configs:

    # server is an optional Consul Agent to connect to. By default, localhost:8500 is used
  - server: "${module.consul_client.listen_host}:${module.consul_client.port}"

- job_name: consul
  metrics_path: '/agent/metrics?format=prometheus'
  consul_sd_configs:
  - server: "${module.consul_client.listen_host}:${module.consul_client.port}"
    token: "${data.consul_acl_token_secret_id.victoria_metrics.secret_id}"

    # datacenter is an optional Consul API datacenter.
    # If the datacenter isn't specified, then it is read from Consul server.
    # See https://www.consul.io/api-docs/agent#read-configuration
    datacenter: "${var.consul_datacenter.name}"

    # namespace is an optional Consul namespace.
    # See https://developer.hashicorp.com/consul/docs/enterprise/namespaces
    # If the namespace isn't specified, then it is read from CONSUL_NAMESPACE environment var.
    # namespace: "..."

    # scheme is an optional scheme (http or https) to use for connecting to Consul server.
    # By default, http scheme is used.
    scheme: "https"

    # services is an optional list of services for which targets are retrieved.
    # If omitted, all services are scraped.
    # See https://www.consul.io/api-docs/catalog#list-nodes-for-service .
    services: ["consul-ui"]

    # tag_separator is an optional string by which Consul tags are joined into the __meta_consul_tags label.
    # By default, "," is used as a tag separator.
    # Individual tags are also available via __meta_consul_tag_<tagname> labels - see below.
    # tag_separator: "..."

    # filter is optional filter for service nodes discovery request.
    # Replaces tags and node_metadata options.
    # consul supports it since 1.14 version
    # list of supported filters https://developer.hashicorp.com/consul/api-docs/catalog#filtering-1
    # syntax examples https://developer.hashicorp.com/consul/api-docs/features/filtering
    # filter: "..."

    # Additional HTTP API client options can be specified here.
    # See https://docs.victoriametrics.com/sd_configs.html#http-api-client-options
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
