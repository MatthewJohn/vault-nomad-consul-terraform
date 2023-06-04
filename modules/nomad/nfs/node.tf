resource "nomad_job" "node" {
  jobspec = <<EOHCL
job "storage-node-${var.nomad_datacenter.name}" {
  datacenters = ["${var.nomad_datacenter.name}"]
  type        = "system"

  group "node" {
    task "node" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:0.6.1"

        args = [
          "--type=node",
          "--node-id=$${attr.unique.hostname}",
          "--nfs-server=${var.nfs_server}:${var.nfs_directory}",
          "--mount-options=defaults,noatime,nolock", # Adjust accordingly
        ]

        # required so the mount works even after stopping the container
        network_mode = "host"

        privileged = true
      }

      csi_plugin {
        id        = "nfs" # Whatever you like, but node & controller config needs to match
        type      = "node"
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
