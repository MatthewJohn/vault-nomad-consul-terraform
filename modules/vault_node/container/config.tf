locals {

  config_value = <<EOF
disable_mlock = true
ui            = true

cluster_addr  = "https://${var.hostname}.${local.vault_domain}:8201"
api_addr      = "https://${var.hostname}.${local.vault_domain}:8200"

storage "raft" {
   path    = "/vault/raft"
   node_id = "${var.hostname}"

   %{for neighbour in var.all_vault_hosts}
   %{if neighbour != var.hostname}
    retry_join 
    {
        leader_api_addr         = "https://${neighbour}.${local.vault_domain}:8200"
        leader_ca_cert_file     = "/vault/ssl/root-ca.pem"
        leader_client_cert_file = "/vault/ssl/server-fullchain.pem"
        leader_client_key_file  = "/vault/ssl/server-privkey.pem"
    }
   %{endif}
   %{endfor}
}

listener "tcp" {
  address            = "0.0.0.0:8200"
  cluster_address    = "0.0.0.0:8201"
  tls_disable        = false
  tls_cert_file      = "/vault/ssl/server-fullchain.pem"
  tls_key_file       = "/vault/ssl/server-privkey.pem"
  tls_client_ca_file = "/vault/ssl/root-ca.pem"
}

EOF

  transit_config = <<EOF
seal "awskms" {
  region     = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  kms_key_id = "ff275b92-0def-4dfc-b0f6-87c96b26c6c7"
  endpoint   = "http://192.168.122.1:8080"
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
    content     = local.config_value
    destination = "/vault/config.d/server.hcl"
  }
}

resource "null_resource" "transit_config" {

  triggers = {
    config = local.transit_config
  }

  connection {
    type = "ssh"
    user = var.docker_username
    host = var.docker_host
  }

  provisioner "file" {
    content     = local.transit_config
    destination = "/vault/config.d/transit.hcl.tmpl"
  }
}

