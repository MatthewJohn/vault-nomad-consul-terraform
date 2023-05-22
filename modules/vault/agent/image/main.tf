resource "docker_image" "this" {
  name = "${var.image_name}:${var.vault_version}"

  keep_locally = true

  build {
    context = "${path.module}/context"

    remove = false
    suppress_output = false

    build_arg = {
      VAULT_VERSION = var.vault_version

      http_proxy = var.http_proxy
      https_proxy = var.http_proxy
      HTTP_PROXY = var.http_proxy
      HTTPS_PROXY = var.http_proxy
    }

    label = {
      author = "Dockstudios Ltd"
    }
  }
}