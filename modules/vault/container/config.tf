locals {

  config_value = <<EOF
disable_mlock = true
ui            = true

storage "file" {
  path = "/vault/file"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/vault/ssl/server-fullchain.pem"
  tls_key_file  = "/vault/ssl/server-privkey.pem"
}

EOF
}

resource "null_resource" "vault_config" {

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
