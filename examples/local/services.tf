module "hello-world-volume" {
  source = "../../modules/nomad/volume"

  name = "hello-world"

  nomad_bootstrap = module.nomad_bootstrap
  nomad_region    = module.nomad_global
  nfs             = module.nomad_nfs_dc1
  uid             = 1000
  gid             = 1000
}

# Test services for deployment (during a standard application deployment)
module "hello-world" {
  source = "../../modules/services/hello_world"

  nomad_bootstrap   = module.nomad_bootstrap
  nomad_region      = module.nomad_global
  nomad_datacenter  = module.nomad_dc1
  consul_root_cert  = module.consul_certificate_authority
  consul_datacenter = module.dc1
  consul_bootstrap  = module.consul_bootstrap
  vault_cluster     = module.vault_cluster
  traefik           = module.traefik
}

module "terrareg" {
  source = "../../modules/services/terrareg"

  nomad_bootstrap   = module.nomad_bootstrap
  nomad_region      = module.nomad_global
  nomad_datacenter  = module.nomad_dc1
  consul_root_cert  = module.consul_certificate_authority
  consul_datacenter = module.dc1
  consul_bootstrap  = module.consul_bootstrap
  vault_cluster     = module.vault_cluster
  traefik           = module.traefik
  nfs               = module.nomad_nfs_dc1
}
