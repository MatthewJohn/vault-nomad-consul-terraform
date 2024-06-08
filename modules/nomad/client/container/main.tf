resource "null_resource" "restart_nomad_client" {
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl restart nomad-client"
    ]
  }

  connection {
    type = "ssh"
    user = var.docker_host.username
    host = var.docker_host.fqdn

    bastion_host = var.docker_host.bastion_host
    bastion_user = var.docker_host.bastion_user

    script_path = "/home/${var.docker_host.username}/restart_nomad.sh"
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.nomad_config,
    ]
  }
}
