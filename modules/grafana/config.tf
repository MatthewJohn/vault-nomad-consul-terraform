resource "random_password" "admin_password" {
  length           = 24
  special          = false
}

locals {
  config_files = {
    "admin_password" = random_password.admin_password.result
  }
}

resource "null_resource" "config" {

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
    destination = "/grafana/config/${each.key}"
  }
}
