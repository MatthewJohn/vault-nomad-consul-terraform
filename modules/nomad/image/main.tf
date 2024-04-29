
resource "null_resource" "image_trigger" {
  triggers = {
    entrypoint = filesha512("${path.module}/context/docker-entrypoint.sh")
    Dockerfile = filesha512("${path.module}/context/Dockerfile")
    http_proxy = var.http_proxy
  }
}

resource "docker_image" "this" {
  name = "nomad-ds:${var.nomad_version}"

  keep_locally = true

  build {
    context = "${path.module}/context"

    remove          = false
    suppress_output = false

    build_args = {
      NOMAD_VERSION  = var.nomad_version
      CONSUL_VERSION = var.consul_version
      VAULT_VERSION  = var.vault_version

      http_proxy = var.http_proxy
    }

    label = {
      author = "Dockstudios Ltd"
    }
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.image_trigger
    ]
  }
}

resource "docker_tag" "this" {
  count = var.remote_image_name != null ? 1 : 0

  source_image = docker_image.this.image_id
  target_image = "${var.remote_image_name}:${var.nomad_version}${var.remote_image_build_number != null ? "-${var.remote_image_build_number}" : ""}"

  lifecycle {
    replace_triggered_by = [
      null_resource.image_trigger
    ]
  }
}

resource "docker_registry_image" "this" {
  count = var.remote_image_name != null ? 1 : 0

  name          = docker_tag.this[count.index].target_image
  keep_remotely = true

  triggers = null_resource.image_trigger.triggers

  lifecycle {
    ignore_changes = [ name ]
  }
}
