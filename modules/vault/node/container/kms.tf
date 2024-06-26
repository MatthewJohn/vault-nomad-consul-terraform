
locals {
  kms_seed_config = <<EOF
Keys:
  Symmetric:
    Aes:
      - Metadata:
          KeyId: ${var.kms_key_id}
        BackingKeys:
          - ${var.kms_backing_key_value}
EOF
}


resource "null_resource" "kms_seed_config" {

  triggers = {
    config = local.kms_seed_config
  }

  connection {
    type = "ssh"
    user = var.docker_host.username
    host = var.docker_host.fqdn

    bastion_host = var.docker_host.bastion_host
    bastion_user = var.docker_host.bastion_user
  }

  provisioner "file" {
    content     = local.kms_seed_config
    destination = "/kms/init/seed.yaml"
  }
}


resource "docker_container" "kms" {
  image = "fare-docker-reg.dock.studios:5000/nsmithuk/local-kms:3.11.4"

  name    = "kms"
  rm      = false
  restart = "always"

  hostname = "kms"

  volumes {
    container_path = "/init"
    host_path      = "/kms/init"
  }

  volumes {
    container_path = "/data"
    host_path      = "/kms/data"
  }

  lifecycle {
    ignore_changes = [
      image,
      log_opts
    ]

    replace_triggered_by = [
      null_resource.kms_seed_config
    ]
  }

  depends_on = [
    null_resource.kms_seed_config
  ]
}
