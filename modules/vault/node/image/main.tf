resource "null_resource" "image_trigger" {
  triggers = {
    "entrypoint"  = filesha512("${path.module}/context/docker-entrypoint.sh")
    "Dockerfile"  = filesha512("${path.module}/context/Dockerfile")
    vault_version = var.vault_version
  }
}

resource "docker_image" "this" {
  name = "vault-ds:${var.vault_version}"

  keep_locally = true

  build {
    context = "${path.module}/context"

    remove          = false
    suppress_output = false

    build_args = {
      VAULT_VERSION = var.vault_version

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