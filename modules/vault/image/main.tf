resource "docker_image" "zoo" {
  name = "vault-ds:${var.vault_version}"
  build {
    context = "context"

    build_arg = {
      vault_version = var.vault_version

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