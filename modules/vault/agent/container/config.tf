locals {

  config_files = {
    "ssl/root-ca.pem"          = file(var.vault_cluster.ca_cert_file)
    "config.d/app-role-id"     = var.app_role_id
    "config.d/app-role-secret" = var.app_role_secret

    "config.d/agent.hcl" = <<EOF
exit_after_auth = false

pid_file = "/tmp/vault-agent.pid"

auto_auth {
  method {
    type = "approle"

    mount_path = "auth/${var.app_role_mount_path}"

    config {
      role_id_file_path   = "/vault-agent/config.d/app-role-id"
      secret_id_file_path = "/vault-agent/config.d/app-role-secret"

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
   ca_cert      = "/vault-agent/ssl/root-ca.pem"
}

EOF
  }
}

resource "null_resource" "config_files" {

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
    destination = "${var.base_directory}/${each.key}"
  }
}
