locals {

  client_fqdn = "client.${var.datacenter.common_name}"

  config_files = {
    "config/templates/client.crt.tpl" = <<EOF
{{- with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.client_ca_role_name}" "common_name=${local.client_fqdn}" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1,${var.docker_host.ip}"}}{{ .Data.certificate }}{{ end }}
{{ with secret "${var.datacenter.pki_mount_path}/cert/ca_chain" }}{{ .Data.ca_chain }}{{ end -}}
EOF

    "config/templates/client.key.tpl" = <<EOF
{{- with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.client_ca_role_name}" "common_name=${local.client_fqdn}" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1,${var.docker_host.ip}"}}{{ .Data.private_key }}{{ end -}}
EOF

    "config/templates/ca.crt.tpl" = <<EOF
${var.vault_cluster.ca_cert}
EOF

    "config/templates/consul_template.hcl" = <<EOF
vault {
  address                = "${var.vault_cluster.address}"
  # @TODO Wrap this token
  unwrap_token           = false
  vault_agent_token_file = "/consul-client-vault-agent-consul-template/auth/token"

  ssl {
    enabled = true
    verify  = true
    ca_cert = "/consul/vault/ca_cert.pem"
  }
}

template {
  source      = "/consul/config/templates/client.crt.tpl"
  destination = "/consul/config/client-certs/client.crt"
  perms       = 0700
}

template {
  source      = "/consul/config/templates/client.key.tpl"
  destination = "/consul/config/client-certs/client.key"
  perms       = 0700
}

template {
  source      = "/consul/config/templates/ca.crt.tpl"
  destination = "/consul/config/client-certs/ca.crt"
  perms       = 0700
}

template {
  source      = "/consul/config/templates/consul.hcl.tmpl"
  destination = "/consul/config/consul.hcl"
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

    "config/templates/consul.hcl.tmpl" = <<EOF
server = false

client_addr        = "${var.listen_host}"
bind_addr          = "${var.docker_host.ip}"
advertise_addr     = "${var.docker_host.ip}"
advertise_addr_wan = "${var.docker_host.ip}"
node_name          = "consul-client-${var.datacenter.name}-${var.docker_host.hostname}"
datacenter         = "${var.datacenter.name}"
domain             = "${var.root_cert.common_name}"

ports {
  # Listener ports
  dns = -1
  http = -1
  https = ${var.listen_port}
  grpc = -1
  grpc_tls = 8503
}

acl {
  enabled = true
  %{if var.use_token_as_default}
  default_policy = "allow"
  %{else}
  default_policy = "deny"
  %{endif}
  enable_token_persistence = false
  enable_token_replication = false
  tokens {
{{ with secret "${var.consul_token.secret_mount}/${var.consul_token.secret_name}" }}
%{if var.use_token_as_default}
    default = "{{ .Data.data.token }}"
%{endif}
    agent  = "{{ .Data.data.token }}"
    # @TODO Create dedicated token for this
    config_file_service_registration = "{{ .Data.data.token }}"
{{ end }}
  }
}

data_dir = "/consul/data"

verify_incoming        = false
verify_outgoing        = true
verify_server_hostname = true

ca_file   = "/consul/config/client-certs/ca.crt"
cert_file = "/consul/config/client-certs/client.crt"
key_file  = "/consul/config/client-certs/client.key"

tls {
  defaults {
    ca_file   = "/consul/config/client-certs/ca.crt"
    cert_file = "/consul/config/client-certs/client.crt"
    key_file  = "/consul/config/client-certs/client.key"

    verify_incoming = false
    verify_outgoing = true
  }
  grpc {
    verify_incoming = false
  }
  internal_rpc {
    verify_server_hostname = true
  }
}

service {
  name = "node_exporter"
  port = 9100

  check {
    name = "node_exporter"
    http = "http://localhost:9100"
    interval = "5s"
    timeout = "5s"
  }
}

connect {
  enabled = true
}

retry_join = ["${var.datacenter.common_name}"]

{{ with secret "${var.datacenter.gossip_encryption.mount}/${var.datacenter.gossip_encryption.name}" }}
encrypt = "{{ .Data.data.value }}"
{{ end }}

encrypt_verify_incoming = true
encrypt_verify_outgoing = true

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

    bastion_user = var.docker_host.bastion_user
    bastion_host = var.docker_host.bastion_host
  }

  provisioner "file" {
    content     = each.value
    destination = "/consul/${each.key}"
  }
}
