resource "nomad_job" "node" {
  jobspec = <<EOHCL
job "nfs-storage-node-${var.service_role.nomad.datacenter}" {
  datacenters = ["${var.service_role.nomad.datacenter}"]
  type        = "system"
  namespace   = "${var.service_role.nomad.namespace}"

  group "node" {
    task "node" {
      driver = "docker"

      config {
        image = "registry.gitlab.com/rocketduck/csi-plugin-nfs:0.6.1"

        args = [
          "--type=node",
          "--endpoint=$${CSI_ENDPOINT}", # provided by csi_plugin{}
          "--node-id=$${attr.unique.hostname}",
          "--nfs-server=${var.nfs_server}:${var.nfs_directory}",
          # "--mount-options=defaults,noatime,nolock", # Adjust accordingly
          "--mount-options=nolock",
          "--log-level=DEBUG",
        ]

        # required so the mount works even after stopping the container
        network_mode = "host"

        privileged = true
      }

      csi_plugin {
        id        = "${local.plugin_id}"
        type      = "node"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 128
        memory = 48
      }
    }
  }
}

EOHCL
}
