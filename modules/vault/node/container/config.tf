locals {

  config_value = <<EOF
disable_mlock = true
ui            = true

cluster_addr  = "https://${var.docker_host.hostname}.${local.vault_domain}:8201"
api_addr      = "https://${var.docker_host.hostname}.${local.vault_domain}:8200"

storage "raft" {
   path    = "/vault/raft"
   node_id = "${var.docker_host.hostname}"

   %{for neighbour in var.all_vault_hosts}
   %{if neighbour != var.docker_host.hostname}
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

seal "awskms" {
  region     = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  kms_key_id = "${var.kms_key_id}"
  endpoint   = "http://${docker_container.kms.network_data[0].ip_address}:8080"
}

telemetry {
  disable_hostname = true
  prometheus_retention_time = "2m"
}

EOF
}

resource "null_resource" "vault_config" {

  triggers = {
    config = local.config_value
  }

  connection {
    type = "ssh"
    user = var.docker_host.username
    host = var.docker_host.fqdn

    bastion_host = var.docker_host.bastion_host
    bastion_user = var.docker_host.bastion_user
  }

  provisioner "file" {
    content     = local.config_value
    destination = "/vault/config.d/server.hcl"
  }
}
