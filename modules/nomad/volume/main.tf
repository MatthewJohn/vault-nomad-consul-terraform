resource "nomad_volume" "this" {
  type        = "csi"
  plugin_id   = var.nfs.plugin_id
  volume_id   = var.name
  name        = var.name
  external_id = local.external_id

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }

  capability {
    access_mode     = "single-node-writer"
    attachment_mode = "file-system"
  }

  capability {
    access_mode     = "multi-node-reader-only"
    attachment_mode = "file-system"
  }
}
