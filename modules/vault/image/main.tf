resource "docker_image" "this" {
  name = "vault-ds:${var.vault_version}"

  build {
    context = "${path.module}/context"

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