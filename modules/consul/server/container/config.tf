locals {

  fqdn = "${var.hostname}.${var.datacenter.common_name}"

  config_files = {
    "templates/agent.crt.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.role_name}" "common_name=${local.fqdn}" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1,${var.docker_ip}"}}
{{ .Data.certificate }}
{{ end }}
EOF

    "templates/agent.key.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.role_name}" "common_name=${local.fqdn}" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1,${var.docker_ip}"}}
{{ .Data.private_key }}
{{ end }}

EOF

    "templates/ca.crt.tpl" = <<EOF
{{ with secret "${var.datacenter.pki_mount_path}/issue/${var.datacenter.role_name}" "common_name=${local.fqdn}" "ttl=24h"}}
{{ .Data.issuing_ca }}
{{ end }}

EOF

    "templates/consul_template.hcl" = <<EOF
vault {
  address      = "${var.vault_cluster.address}"

  unwrap_token = false
  renew_token  = false
}

template {
  source      = "/consul/config/templates/agent.crt.tpl"
  destination = "/consul/config/agent-certs/agent.crt"
  perms       = 0700
  command     = "sh -c 'date && consul reload'"
}

template {
  source      = "/consul/config/templates/agent.key.tpl"
  destination = "/consul/config/agent-certs/agent.key"
  perms       = 0700
  command     = "sh -c 'date && consul reload'"
}

template {
  source      = "/consul/config/templates/ca.crt.tpl"
  destination = "/consul/config/agent-certs/ca.crt"
  command     = "sh -c 'date && consul reload'"
}
EOF

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
    destination = "/consul/config/${each.key}"
  }
}
