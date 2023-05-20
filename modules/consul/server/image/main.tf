resource "docker_image" "this" {
  name = "consul-ds:${var.consul_version}"

  keep_locally = true

  build {
    context = "${path.module}/context"

    remove = false
    suppress_output = false

    build_arg = {
      CONSUL_VERSION = var.consul_version

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