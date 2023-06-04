resource "nomad_job" "node" {
  jobspec = <<EOHCL
job "plugin-nfs-nodes-${var.nomad_datacenter.name}" {
  datacenters = ["${var.nomad_datacenter.name}"]
  # you can run node plugins as service jobs as well, but this ensures
  # that all nodes in the DC have a copy.
  type = "system"
  group "nodes" {
    task "plugin" {
      driver = "docker"
      config {
        image = "registry.k8s.io/sig-storage/nfsplugin:v4.1.0"
        args = [
          "--v=5",
          "--nodeid=$${attr.unique.hostname}",
          "--endpoint=unix:///csi/csi.sock",
          "--drivername=nfs.csi.k8s.io"
        ]
        # node plugins must run as privileged jobs because they
        # mount disks to the host
        privileged = true
      }
      csi_plugin {
        id        = "nfsofficial"
        type      = "node"
        mount_dir = "/csi"
      }
      resources {
        memory = 10
      }
    }
  }
}
EOHCL
}
