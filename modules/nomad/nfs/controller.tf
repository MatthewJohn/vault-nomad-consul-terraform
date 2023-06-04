resource "nomad_job" "controller" {
  jobspec = <<EOHCL
job "nfs-storage-controller-${var.nomad_datacenter.name}" {
  datacenters = ["${var.nomad_datacenter.name}"]
  type        = "service"

  group "controller" {
    task "controller" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:0.6.1"

        args = [
          "--type=controller",
          "--endpoint=$${CSI_ENDPOINT}", # provided by csi_plugin{}
          "--node-id=$${attr.unique.hostname}",
          "--nfs-server=${var.nfs_server}:${var.nfs_directory}",
          # "--mount-options=defaults,noatime,nolock", # Adjust 
          "--mount-options=nolock",
          "--log-level=DEBUG",
        ]

        network_mode = "host" # required so the mount works even after stopping the container

        privileged = true
      }

      csi_plugin {
        id        = "nfs" # Whatever you like, but node & controller config needs to match
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 128
        memory = 64
      }
    }
  }
}

EOHCL
}
