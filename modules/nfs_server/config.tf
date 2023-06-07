
locals {
  export_config = <<EOF
%{for mount in var.exports}
${mount.directory} %{for client in mount.clients} ${client}(${mount.options})%{endfor}
%{endfor}
EOF
}

resource "null_resource" "exports" {

  triggers = {
    config = local.export_config
  }

  connection {
    type = "ssh"
    user = var.docker_username
    host = var.docker_host
  }

  provisioner "file" {
    content     = local.export_config
    destination = "${var.data_directory}/exports"
  }
}
