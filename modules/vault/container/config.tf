locals {

  config_value = <<EOF
disable_mlock = true
ui            = true

cluster_addr  = "https://${var.docker_ip}:8201"
api_addr      = "https://${var.docker_ip}:8200"

ha_storage "raft" {
   path    = "/vault/raft"
   node_id = "${var.hostname}"
}

storage "file" {
  path = "/vault/file"
}

listener "tcp" {
  address            = "0.0.0.0:8200"
  cluster_address    = "0.0.0.0:8201"
  tls_cert_file      = "/vault/ssl/server-fullchain.pem"
  tls_key_file       = "/vault/ssl/server-privkey.pem"
  tls_client_ca_file = "/vault/ssl/root-ca.pem"
}

EOF
}

resource "null_resource" "vault_config" {

  triggers = {
    config = local.config_value
  }

  connection {
    type = "ssh"
    user = var.docker_username
    host = var.docker_host
  }

  provisioner "file" {
    content = local.config_value
    destination = "/vault/config.d/server.hcl"
  }
}
