locals {

  fqdn = "${var.hostname}.${var.datacenter.common_name}"

  config_files = {
    "config/templates/agent.crt.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.role_name}" "common_name=${local.fqdn}" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1,${var.docker_ip}"}}
{{ .Data.certificate }}
{{ end }}
EOF

    "config/templates/agent.key.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.role_name}" "common_name=${local.fqdn}" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1,${var.docker_ip}"}}
{{ .Data.private_key }}
{{ end }}

EOF

    "config/templates/ca.crt.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.role_name}" "common_name=${local.fqdn}" "ttl=24h"}}
{{ .Data.issuing_ca }}
{{ end }}

EOF

    "config/templates/consul_template.hcl" = <<EOF
vault {
  address      = "${var.vault_cluster.address}"
  unwrap_token = false
  renew_token  = true

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

# This controls whether an error within a template will cause consul-template
# to immediately exit. This value can be overridden within each template
# configuration.
template_error_fatal = true

# This will cause consul-template to exit with an error if it fails to
# successfully fetch a value for a field. Note that the retry logic defined for
# the services don't apply to this type of error.
err_on_failed_lookup = true

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

    "consul.hcl" = <<EOF

bootstrap_expect = 1

server = true

client_addr = "0.0.0.0"
bind_addr        = "${var.docker_ip}"
advertise_addr   = "${var.docker_ip}"
advertise_addr_wan = "${var.docker_ip}"
datacenter  = "${var.datacenter.name}"
domain      = "${var.root_cert.common_name}"

ui = true

data_dir = "/consul/data"

verify_incoming        = true
verify_outgoing        = true
verify_server_hostname = true

ca_file   = "/consul/config/agent-certs/ca.crt"
cert_file = "/consul/config/agent-certs/agent.crt"
key_file  = "/consul/config/agent-certs/agent.key"

auto_encrypt {
  allow_tls = true
}

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
    user = var.docker_username
    host = var.docker_host
  }

  provisioner "file" {
    content     = each.value
    destination = "/consul/${each.key}"
  }
}
