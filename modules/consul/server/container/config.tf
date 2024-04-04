locals {

  fqdn        = "${var.docker_host.hostname}.${var.datacenter.common_name}"
  server_fqdn = "server.${var.datacenter.common_name}"

  config_files = {
    "config/templates/agent.crt.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.role_name}" "common_name=${local.server_fqdn}" "ttl=24h" "alt_names=${local.fqdn},${var.datacenter.common_name},localhost" "ip_sans=127.0.0.1,${var.docker_host.ip}"}}
{{ .Data.certificate }}
{{ .Data.issuing_ca }}
{{ end }}
EOF

    "config/templates/agent.key.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.role_name}" "common_name=${local.server_fqdn}" "ttl=24h" "alt_names=${local.fqdn},${var.datacenter.common_name},localhost" "ip_sans=127.0.0.1,${var.docker_host.ip}"}}
{{ .Data.private_key }}
{{ end }}

EOF

    "config/templates/ca.crt.tpl" = <<EOF
{{- with secret "${var.datacenter.pki_mount_path}/cert/ca_chain" -}}
{{ .Data.ca_chain }}
{{- end -}}
EOF

    "config/templates/consul_template.hcl" = <<EOF
vault {
  address                = "${var.vault_cluster.address}"
  # @TODO Wrap this token
  unwrap_token           = false
  vault_agent_token_file = "/vault-agent-consul-template/auth/token"

  ssl {
    enabled = true
    verify  = true
    ca_cert = "/consul/vault/ca_cert.pem"
  }
}

template {
  source      = "/consul/config/templates/agent.crt.tpl"
  destination = "/consul/config/agent-certs/agent.crt"
  perms       = 0700
}

template {
  source      = "/consul/config/templates/agent.key.tpl"
  destination = "/consul/config/agent-certs/agent.key"
  perms       = 0700
}

template {
  source      = "/consul/config/templates/ca.crt.tpl"
  destination = "/consul/config/agent-certs/ca.crt"
  perms       = 0700
}

template {
  source      = "/consul/config/templates/consul.hcl.tmpl"
  destination = "/consul/config/consul.hcl"
  perms       = 0700

  error_on_missing_key = false
  error_fatal = false
}

# This is the signal to listen for to trigger a reload event. The default
# value is shown below. Setting this value to the empty string will cause CT
# to not listen for any reload signals.
reload_signal = "SIGHUP"

# This is the signal to listen for to trigger a graceful stop. The default
# value is shown below. Setting this value to the empty string will cause CT
# to not listen for any graceful stop signals.
kill_signal = "SIGINT"

# This is the maximum interval to allow "stale" data. By default, only the
# Consul leader will respond to queries; any requests to a follower will
# forward to the leader. In large clusters with many requests, this is not as
# scalable, so this option allows any follower to respond to a query, so long
# as the last-replicated data is within these bounds. Higher values result in
# less cluster load, but are more likely to have outdated data.
max_stale = "10m"

# This is amount of time in seconds to do a blocking query for.
# Many endpoints in Consul support a feature known as "blocking queries".
# A blocking query is used to wait for a potential change using long polling.
block_query_wait = "60s"

# This is the log level. This is also available as a command line flag.
# Valid options include (in order of verbosity): trace, debug, info, warn, err
log_level = "warn"

# Do not fail on lookup errors.
# If the consul cluster is down during startup, vault
# will be unable to fetch the consul access tokens,
# which would normally cause a failure.
# Allow the template to continue.
# If any values that are truly need fail (CA cert etc),
# consul will fail to startup and the container will restart. 
template_error_fatal = false
err_on_failed_lookup = false

# This is the quiescence timers; it defines the minimum and maximum amount of
# time to wait for the cluster to reach a consistent state before rendering a
# template. This is useful to enable in systems that have a lot of flapping,
# because it will reduce the the number of times a template is rendered.
wait {
  min = "5s"
  max = "10s"
}

EOF

    "vault/ca_cert.pem" = file(var.vault_cluster.ca_cert_file)

    "config/templates/consul.hcl.tmpl" = <<EOF

%{if var.initial_run == true}
bootstrap_expect = ${local.bootstrap_count}
%{endif}

server = true

client_addr        = "0.0.0.0"
bind_addr          = "${var.docker_host.ip}"
advertise_addr     = "${var.docker_host.ip}"
advertise_addr_wan = "${var.docker_host.ip}"
node_name          = "consul-server-${var.datacenter.name}-${var.docker_host.hostname}"
datacenter         = "${var.datacenter.name}"
domain             = "${var.root_cert.common_name}"

ports {
  # Listener ports
  dns = 53
  http = 8500
  https = 8501
  grpc_tls = 8503
}

acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = false
  # @TODO Determine after testing multiple consul DCs
  enable_token_replication = false
  tokens {
{{- with secret "${var.datacenter.consul_server_token.mount}/${var.datacenter.consul_server_token.name}" -}}
{{ if eq .Data.server_token "" }}
    agent                            = "{{ .Data.server_token }}"
{{- end -}}
{{ if eq .Data.server_service_token "" }}
    config_file_service_registration = "{{ .Data.server_service_token }}"
{{- end -}}
{{- end -}}
  }
}

data_dir = "/consul/data"

verify_incoming        = false
verify_incoming_rpc    = true
verify_outgoing        = true
verify_server_hostname = true

ca_file   = "/consul/config/agent-certs/ca.crt"
cert_file = "/consul/config/agent-certs/agent.crt"
key_file  = "/consul/config/agent-certs/agent.key"

tls {
   defaults {
      ca_file   = "/consul/config/agent-certs/ca.crt"
      cert_file = "/consul/config/agent-certs/agent.crt"
      key_file  = "/consul/config/agent-certs/agent.key"

      verify_incoming        = true
      verify_outgoing        = true
   }
   https {
     # Disable incoming https verification
     # to allow UI access, terraform and services lik traefik
     verify_incoming = false
   }

   internal_rpc {
      verify_server_hostname = true
   }
}

connect {
  enabled = true
  ca_provider = "vault"
  ca_config {
    address = "${var.vault_cluster.address}"
    
    auth_method {
      type = "approle"
      mount_path = "${var.datacenter.approle_mount_path}"
      params {
        role_id   = "${var.connect_ca_approle_role_id}"
        secret_id = "${var.connect_ca_approle_secret_id}"
      }
      ca_file = "/consul/vault/ca_cert.pem"
    }

    root_pki_path         = "${var.root_cert.pki_connect_mount_path}"
    intermediate_pki_path = "${var.datacenter.pki_connect_mount_path}"

    leaf_cert_ttl         = "72h"
    rotation_period       = "2160h"
    intermediate_cert_ttl = "8760h"
    private_key_type      = "rsa"
    private_key_bits      = 2048
  }
}

services {
  name = "consul-ui"
  id   = "consul-ui"
  port = 8501
  tags = ["https"]
}

services {
  name = "node_exporter"
  port = 9100

  check {
    name = "node_exporter"
    http = "http://localhost:9100"
    interval = "5s"
    timeout = "5s"
  }
}

telemetry {
  prometheus_retention_time = "2m"
  disable_hostname          = true
  # Causes error:
  # * invalid config key telemetry.enable_host_metrics
  enable_host_metrics       = true
}

ui_config {
  enabled = true

  # metrics_provider = "prometheus"
  # metrics_proxy {
  #   base_url = "https://"
  # }
}

retry_join = ["${var.datacenter.common_name}"]

auto_encrypt {
  allow_tls = true
}

encrypt = "${var.gossip_key}"

disable_update_check = true

EOF
  }
}

resource "null_resource" "consul_config" {

  for_each = local.config_files

  triggers = {
    config = each.value
  }

  connection {
    type = "ssh"
    user = var.docker_host.username
    host = var.docker_host.fqdn

    bastion_host = var.docker_host.bastion_host
    bastion_user = var.docker_host.bastion_user
  }

  provisioner "file" {
    content     = each.value
    destination = "/consul/${each.key}"
  }
}
