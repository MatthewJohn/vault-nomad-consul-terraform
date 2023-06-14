# Create NFS container
resource "docker_container" "this" {
  image = "fare-docker-reg.dock.studios:5000/googlecloudplatform/nfs-server-docker:1.0.0"

  name    = "nfs-server"
  rm      = false
  restart = "on-failure"

  hostname   = "${var.hostname}.${var.domain_name}"
  domainname = ""

  network_mode = "host"

  capabilities {
    add = ["SYS_ADMIN", "SYS_MODULE"]
  }

  privileged = true

  # entrypoint = ["sh", "-c", "sleep 50000"]

  mounts {
    target = var.data_directory
    type   = "bind"
    source = var.data_directory
    bind_options {
      propagation = "shared"
    }
  }

  volumes {
    host_path      = "${var.data_directory}/exports"
    container_path = "/etc/exports"
    read_only      = true
  }

  volumes {
    host_path      = "/lib/modules"
    container_path = "/lib/modules"
    read_only      = true
  }

  lifecycle {
    ignore_changes = [image]
  }
}
