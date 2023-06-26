resource "nomad_volume" "this" {
  type        = "csi"
  plugin_id   = var.nfs.plugin_id
  volume_id   = var.name
  name        = var.name
  external_id = local.external_id
  namespace   = var.namespace

  capability {
    access_mode     = "multi-node-multi-writer"
    attachment_mode = "file-system"
  }

  parameters = {
    uid  = var.uid
    gid  = var.gid
    mode = var.mode
  }
}
