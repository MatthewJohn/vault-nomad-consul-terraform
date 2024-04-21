locals {

  client_fqdn = "client.${var.datacenter.common_name}"

  config_files = {
    "config/templates/client.crt.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.client_ca_role_name}" "common_name=${local.client_fqdn}" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1,${var.docker_host.ip}"}}
{{ .Data.certificate }}
{{ end }}
{{- with secret "${var.datacenter.pki_mount_path}/cert/ca_chain" -}}
{{ .Data.ca_chain }}
{{- end -}}
EOF

    "config/templates/client.key.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.client_ca_role_name}" "common_name=${local.client_fqdn}" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1,${var.docker_host.ip}"}}
{{ .Data.private_key }}
{{ end }}
EOF

    "config/templates/ca.crt.tpl" = <<EOF
{{- with secret "${var.datacenter.pki_mount_path}/cert/ca_chain" -}}
{{ .Data.ca_chain }}
{{- end -}}
EOF

    "config/templates/app-role-id" = var.app_role_id
    "config/templates/app-role-secret" = var.app_role_secret

    "config/templates/consul_template.hcl" = <<EOF
exit_after_auth = false

pid_file = "/tmp/vault-agent.pid"

auto_auth {
  method {
    type = "approle"

    mount_path = "auth/${var.app_role_mount_path}"

    config {
      role_id_file_path   = "/consul/config/templates/app-role-id"
      secret_id_file_path = "/consul/config/templates/app-role-secret"

      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    # @TODO support unwrapping
    #wrap_ttl = "5m"
    config = {
      path = "/vault-agent/auth/token"
    }
  }
}
vault {
   address      = "${var.vault_cluster.address}"
   ca_cert      = "/consul/vault/ca_cert.pem"
}

template_config {
  exit_on_retry_failure = true
  static_secret_render_interval = "10m"
  max_connections_per_host = 20
}

template {
  source      = "/consul/config/templates/client.crt.tpl"
  destination = "/consul/config/client-certs/client.crt"
  perms       = 0700
  backup      = false
}

template {
  source      = "/consul/config/templates/client.key.tpl"
  destination = "/consul/config/client-certs/client.key"
  perms       = 0700
  backup      = false
}

template {
  source      = "/consul/config/templates/ca.crt.tpl"
  destination = "/consul/config/client-certs/ca.crt"
  perms       = 0700
  backup      = false
}

template {
  source      = "/consul/config/templates/consul.hcl.tmpl"
  destination = "/consul/config/consul.hcl"
  perms       = 0700
  backup      = false

  error_on_missing_key = false
}

exec {
  command                   = ["consul", "agent", "-config-file", "/consul/config/consul.hcl", "-config-format", "hcl"]
  restart_on_secret_changes = "always"
  restart_stop_signal       = "SIGHUP"
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
  dns = 53
  http = -1
  https = ${var.listen_port}
  grpc = -1
  grpc_tls = 8503
}

acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = false
  enable_token_replication = false
  tokens {
{{ with secret "${var.datacenter.consul_engine_mount_path}/creds/consul-client-role" }}
    agent  = "{{ .Data.token }}"
    # @TODO Create dedicated token for this
    config_file_service_registration = "{{ .Data.token }}"
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
