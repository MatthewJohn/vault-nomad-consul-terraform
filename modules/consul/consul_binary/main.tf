
resource "null_resource" "download_and_extract" {
  triggers = {
    "consul_version" = var.consul_version
  }

  provisioner "local-exec" {
    command = "${path.module}/download_consul.sh"

    environment = {
      CONSUL_VERSION = var.consul_version
     }
  }
}
