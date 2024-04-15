
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