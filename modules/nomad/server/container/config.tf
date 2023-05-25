locals {

  fqdn        = "${var.hostname}.${var.region.common_name}"
  server_fqdn = "server.${var.region.common_name}"
  # Static domain used to verify SSL cert, see https://github.com/hashicorp/nomad/blob/9ff1d927d9f7900926b8ad6f545532415a3fcc3d/helper/tlsutil/config.go#L291
  verify_domain = "server.${var.region.name}.nomad"

  config_files = {
    "config/templates/server.crt.tpl" = <<EOF
{{ with secret "${var.region.pki_mount_path}/issue/${var.region.role_name}" "common_name=${local.verify_domain}" "ttl=24h" "alt_names=${local.server_fqdn},${local.fqdn},localhost" "ip_sans=127.0.0.1,${var.docker_ip}"}}
{{ .Data.certificate }}
{{ end }}
EOF

    "config/templates/server.key.tpl" = <<EOF
{{ with secret "${var.region.pki_mount_path}/issue/${var.region.role_name}" "common_name=${local.verify_domain}" "ttl=24h" "alt_names=${local.server_fqdn},${local.fqdn},localhost" "ip_sans=127.0.0.1,${var.docker_ip}"}}
{{ .Data.private_key }}
{{ end }}

EOF

    "config/templates/ca.crt.tpl" = <<EOF
{{ with secret "${var.region.pki_mount_path}/issue/${var.region.role_name}" "common_name=${local.verify_domain}" "ttl=24h"}}
{{ .Data.issuing_ca }}
{{ end }}

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
    ca_cert = "/nomad/vault/ca_cert.pem"
  }
}

template {
  source      = "/nomad/config/templates/server.crt.tpl"
  destination = "/nomad/config/server-certs/server.crt"
  perms       = 0700
}

template {
  source      = "/nomad/config/templates/server.key.tpl"
  destination = "/nomad/config/server-certs/server.key"
  perms       = 0700
}

template {
  source      = "/nomad/config/templates/ca.crt.tpl"
  destination = "/nomad/config/server-certs/ca.crt"
  perms       = 0700
}

template {
  source      = "/nomad/config/templates/server.hcl.tmpl"
  destination = "/nomad/config/server.hcl"
  perms       = 0700

  error_on_missing_key = false
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

    "config/templates/server.hcl.tmpl" = <<EOF

name = "${var.hostname}"

region = "${var.region.name}"

bind_addr = "0.0.0.0"

server {
  enabled          = true
  %{if var.initial_run == true}
  bootstrap_expect = ${local.bootstrap_count}
  %{endif}
  server_join {
    retry_join = [ "${var.region.common_name}" ]
    retry_max = 3
    retry_interval = "15s"
  }
}

tls {
  http = true
  rpc  = true

  ca_file   = "/nomad/config/server-certs/ca.crt"
  cert_file = "/nomad/config/server-certs/server.crt"
  key_file  = "/nomad/config/server-certs/server.key"

  verify_server_hostname = true
}

data_dir = "/nomad/data"

disable_update_check = true

EOF
}
}

resource "null_resource" "noamd_config" {

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
    destination = "/nomad/${each.key}"
  }
}