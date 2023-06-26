# Generate service roles:
# In a CI/CD perspective, these are created
# once outside of the context of the application,
# the outputs are provided *to* the application
# deployment, which provide restricted permissions
# for the application to be deployed.
module "hello-world_service_role" {

  source = "../../modules/service_role"

  name = "hello-world"

  nomad_bootstrap     = module.nomad_bootstrap
  nomad_region        = module.nomad_global
  nomad_datacenter    = module.nomad_dc1
  consul_root_cert    = module.consul_certificate_authority
  consul_datacenter   = module.dc1
  consul_bootstrap    = module.consul_bootstrap
  vault_cluster       = module.vault_cluster
  nomad_static_tokens = module.nomad_static_tokens
}

module "terrareg_service_role" {

  source = "../../modules/service_role"

  name = "terrareg"

  nomad_bootstrap       = module.nomad_bootstrap
  nomad_region          = module.nomad_global
  nomad_datacenter      = module.nomad_dc1
  consul_root_cert      = module.consul_certificate_authority
  consul_datacenter     = module.dc1
  consul_bootstrap      = module.consul_bootstrap
  vault_cluster         = module.vault_cluster
  nomad_static_tokens   = module.nomad_static_tokens
  allow_volume_creation = true
}


# Test services for deployment (during a standard application deployment)
module "hello-world" {
  source = "../../modules/services/hello_world"

  service_role      = module.hello-world_service_role
  traefik           = module.traefik
}

module "terrareg" {
  source = "../../modules/services/terrareg"

  service_role      = module.terrareg_service_role
  traefik           = module.traefik
  nfs               = module.nomad_nfs_dc1
}
