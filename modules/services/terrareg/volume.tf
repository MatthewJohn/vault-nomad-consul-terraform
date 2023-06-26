
module "volume" {
  source = "../../nomad/volume"

  name = "terrareg"

  nfs = var.nfs
  uid = 0
  gid = 0
}
