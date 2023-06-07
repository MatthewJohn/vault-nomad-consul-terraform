
module "volume" {
  source = "../../nomad/volume"

  name = "terrareg"

  nomad_bootstrap = var.nomad_bootstrap
  nomad_region    = var.nomad_region
  nfs             = var.nfs
  uid             = 0
  gid             = 0
}
