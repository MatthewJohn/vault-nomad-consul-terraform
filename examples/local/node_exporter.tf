module "node_exporter_vault-1" {
  source = "../../modules/node_exporter"

  hostname    = "vault-1"
  domain_name = local.domain_name

  docker_host = module.virtual_machines.virtual_machines.vault-1
}

module "node_exporter_vault-2" {
  source = "../../modules/node_exporter"

  hostname    = "vault-2"
  domain_name = local.domain_name

  docker_host = module.virtual_machines.virtual_machines.vault-2
}

module "node_exporter_consul-1" {
  source = "../../modules/node_exporter"

  hostname    = "consul-1"
  domain_name = local.domain_name

  docker_host = module.virtual_machines.virtual_machines.consul-1
}

module "node_exporter_consul-2" {
  source = "../../modules/node_exporter"

  hostname    = "consul-2"
  domain_name = local.domain_name

  docker_host = module.virtual_machines.virtual_machines.consul-2
}

module "node_exporter_consul-3" {
  source = "../../modules/node_exporter"

  hostname    = "consul-3"
  domain_name = local.domain_name

  docker_host = module.virtual_machines.virtual_machines.consul-3
}

module "node_exporter_nomad-1" {
  source = "../../modules/node_exporter"

  hostname    = "nomad-1"
  domain_name = local.domain_name

  docker_host = module.virtual_machines.virtual_machines.nomad-1
}

module "node_exporter_nomad-2" {
  source = "../../modules/node_exporter"

  hostname    = "nomad-2"
  domain_name = local.domain_name

  docker_host = module.virtual_machines.virtual_machines.nomad-2
}

module "node_exporter_nomad-client-1" {
  source = "../../modules/node_exporter"

  hostname    = "nomad-client-1"
  domain_name = local.domain_name

  docker_host = module.virtual_machines.virtual_machines.nomad-client-1
}
