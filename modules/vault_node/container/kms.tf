
resource "random_id" "kms_key_id" {
  # Generates 32 hex characters
  byte_length = 16
}

resource "random_id" "kms_backing_key" {
  # Generates 64 hex characters
  byte_length = 32
}

locals {

  # Generate KMS key ID, splitting up random value
  kms_key_id = join(
    "-",
    [
      substr(random_id.kms_key_id.hex, 0, 8),
      substr(random_id.kms_key_id.hex, 8, 4),
      substr(random_id.kms_key_id.hex, 12, 4),
      substr(random_id.kms_key_id.hex, 16, 4),
      substr(random_id.kms_key_id.hex, 20, 12)
    ]
  )

  kms_seed_config = <<EOF
Keys:
  Symmetric:
    Aes:
      - Metadata:
          KeyId: ${local.kms_key_id}
        BackingKeys:
          - ${random_id.kms_backing_key.hex}
EOF
}

resource "null_resource" "kms_seed_config" {

  triggers = {
    config = local.kms_seed_config
  }

  connection {
    type = "ssh"
    user = var.docker_username
    host = var.docker_host
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
  restart = "on-failure"

  hostname   = "kms"

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
      image
    ]

    replace_triggered_by = [
      null_resource.kms_seed_config
    ]
  }
}
