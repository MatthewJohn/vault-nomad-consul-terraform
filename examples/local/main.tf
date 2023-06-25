
locals {
  freeipa_admin    = "admin"
  freeipa_password = "password"
  domain_name      = "dock.local"
  docker_username  = "docker-connect"

  aws_profile  = "dockstudios-terraform"
  aws_region   = "eu-east-1"
  aws_endpoint = "http://s3.dock.local:9000"
}

module "freeipa" {
  source  = "terraform-registry.dockstudios.co.uk/dockstudios/local-freeipa/docker"
  version = "1.0.0"

  freeipa_password = local.freeipa_password
}

resource "libvirt_pool" "local-disks" {
  name = "local-disks"
  type = "dir"
  path = "/local-ds-setup/vm-disks"
}

module "virtual_machines" {
  source = "../../modules/virtual_machines"

  base_disk_path      = "/local-ds-setup/vm-disks"
  base_image_path     = "/local-ds-setup/vm-disks"
  hypervisor_hostname = "localhost"
  hypervisor_username = "matthew"
  nameservers         = [module.freeipa.ip_address]
  docker_ssh_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcGH/YaonGEDCKOwx8IX9OwihRJ7OkINQYxx1bTnB+9EQQGPEMbzTMWQWFPamlNLdhdutQuRS4CWASAW3S+jDqbEy4KIngW1hNzEdS+pd2xoAm9jdd7Xv46n6YYfC6tTMMY/mvX3cUJmFMDEpHMCEALOkQR55vCNp3ru7Slm5Jb8Ou6QzGrNMYZmrIfgaclq6qHE/eRDqah7vo8ufXwFmtNk7BXc9cV///6fHUg7oGeYgjCtyRiNUIKarI4fFAcsDOfaXX9RQuPUfAs+7qCMJ78dMnjmpQM5YQenuaraunitLVLLTFDXD1tIHV4KUoStOF3aBuonDWshZuE8GntzmY5kKqKWoKcycU/HrlnhMaWlzj1xgh6TwW1XgLrttPqL3+jbBs65Z+1HTWAxjgcm88tSG/3B1+SJCsWGnK6WpESlJ4vpvXbxgJB5nZDXlc/J9ncxD0meCYSMjOvZYjHLOp58n0WAx3JstMVi/BHQ4ekVc+lxwgfFz2VPy8mNO0PWGqSDdWrIUSCjw0+ujvmUgCoj5S/5LwvMyZQj9wyQBwANFeY+D+Dn5vwDK+A7kUz/KM5u6zoU0UF5QwAVmDuChiYnIRI4EtL5DkmclbMKTZcbNQtN4OuliehIZB94sHu9d2L6k10hX/V5NW+ezczu5LQtbxbx9L1CQAXhF3FQqfXw== matthew@laptop21"
  domain_name         = "dock.local"

  # Add DNS for fare-docker-reg.dock.studios
  hosts_entries = {
    "172.16.93.12" : ["fare-docker-reg.dock.studios"]
  }

  vault_hosts = {
    "vault-1" = {
      ip_address               = "192.168.122.60"
      ip_gateway               = "192.168.122.1"
      network_bridge           = "virbr0"
      additional_dns_hostnames = ["vault-1.vault.dock.local"]
    }
    "vault-2" = {
      ip_address               = "192.168.122.61"
      ip_gateway               = "192.168.122.1"
      network_bridge           = "virbr0"
      additional_dns_hostnames = ["vault-2.vault.dock.local"]
    }
  }
  consul_hosts = {
    "consul-1" = {
      ip_address               = "192.168.122.71"
      ip_gateway               = "192.168.122.1"
      network_bridge           = "virbr0"
      additional_dns_hostnames = ["consul-1.dc1.consul.dock.local"]
    }
    "consul-2" = {
      ip_address               = "192.168.122.72"
      ip_gateway               = "192.168.122.1"
      network_bridge           = "virbr0"
      additional_dns_hostnames = ["consul-2.dc1.consul.dock.local"]
    }
    "consul-3" = {
      ip_address               = "192.168.122.73"
      ip_gateway               = "192.168.122.1"
      network_bridge           = "virbr0"
      additional_dns_hostnames = ["consul-3.dc1.consul.dock.local"]
    }
  }
  nomad_server_hosts = {
    "nomad-1" = {
      ip_address     = "192.168.122.81"
      ip_gateway     = "192.168.122.1"
      network_bridge = "virbr0"
    }
    "nomad-2" = {
      ip_address     = "192.168.122.82"
      ip_gateway     = "192.168.122.1"
      network_bridge = "virbr0"
    }
  }
  nomad_client_hosts = {
    "nomad-client-1" = {
      ip_address     = "192.168.122.91"
      ip_gateway     = "192.168.122.1"
      network_bridge = "virbr0"
    }
  }
  storage_server = {
    ip_address     = "192.168.122.51"
    ip_gateway     = "192.168.122.1"
    name           = "nfs-1"
    network_bridge = "virbr0"
    directories    = ["/storage", "/storage/dc1"]
  }
  monitoring_server = {
    ip_address     = "192.168.122.52"
    ip_gateway     = "192.168.122.1"
    name           = "mon-1"
    network_bridge = "virbr0"
  }
}

locals {
  all_vault_hosts      = ["vault-1", "vault-2"]
  all_vault_host_ips   = ["192.168.122.60", "192.168.122.61"]
  all_consul_ips       = ["192.168.122.71", "192.168.122.72", "192.168.122.73"]
  all_nomad_server_ips = ["192.168.122.81", "192.168.122.82"]
  all_nomad_client_ips = ["192.168.122.91"]
}

module "nfs_server" {
  source = "../../modules/nfs_server"

  hostname       = "nfs-1"
  domain_name    = local.domain_name
  data_directory = "/storage"
  exports = [
    {
      directory = "/storage/dc1"
      clients = [
        "192.168.122.81",
        "192.168.122.82",
        "192.168.122.91"
      ]
    }
  ]

  docker_username = "docker-connect"
  docker_host     = "nfs-1.${local.domain_name}"
  docker_ip       = "192.168.122.51"
}

module "vault_init" {
  source = "../../modules/vault/init"

  # vault-1 IP
  vault_host        = "vault-1.dock.local"
  aws_region        = local.aws_region
  aws_endpoint      = local.aws_endpoint
  aws_profile       = local.aws_profile
  bucket_name       = "vault-unseal"
  initial_run       = var.initial_setup
  host_ssh_username = "docker-connect"
}

module "vault_cluster" {
  source = "../../modules/vault/cluster"

  domain_name        = local.domain_name
  ip_addresses       = local.all_vault_host_ips
  root_token         = module.vault_init.root_token
  ca_cert_file       = module.vault_init.ca_cert_file
  setup_host         = "vault-2.vault.dock.local"
  consul_datacenters = ["dc1"]
  nomad_regions      = { "global" = ["dc1"] }
}

module "kms_config" {
  source = "../../modules/kms_config"
}

module "vault-1" {
  source = "../../modules/vault/node"

  domain_name     = local.domain_name
  hostname        = "vault-1"
  all_vault_hosts = local.all_vault_hosts

  docker_host     = "vault-1.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.60"

  kms_key_id            = module.kms_config.key_id
  kms_backing_key_value = module.kms_config.backing_key_value
}

module "vault_1-consul_client" {
  source = "../../modules/consul/client"

  hostname      = "vault-1"
  domain_name   = local.domain_name
  datacenter    = module.dc1
  vault_cluster = module.vault_cluster
  root_cert     = module.consul_certificate_authority
  gossip_key    = module.consul_gossip_encryption.secret

  consul_version = "1.15.3"

  docker_host     = "vault-1.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.60"
}

module "vault-2" {
  source = "../../modules/vault/node"

  domain_name     = local.domain_name
  hostname        = "vault-2"
  all_vault_hosts = local.all_vault_hosts

  docker_host     = "vault-2.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.61"

  kms_key_id            = module.kms_config.key_id
  kms_backing_key_value = module.kms_config.backing_key_value
}

module "vault_2-consul_client" {
  source = "../../modules/consul/client"

  hostname      = "vault-2"
  domain_name   = local.domain_name
  datacenter    = module.dc1
  vault_cluster = module.vault_cluster
  root_cert     = module.consul_certificate_authority
  gossip_key    = module.consul_gossip_encryption.secret

  consul_version = "1.15.3"

  docker_host     = "vault-2.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.61"
}

module "consul_certificate_authority" {
  source = "../../modules/certificate_authority"

  domain_name       = local.domain_name
  subdomain         = "consul"
  vault_cluster     = module.vault_cluster
  description       = "Consul CA"
  mount_name        = "consul"
  create_connect_ca = true
}

module "consul_global_config" {
  source = "../../modules/consul/global_config"

  primary_datacenter = "dc1"
}

module "dc1" {
  source = "../../modules/consul/datacenter"

  datacenter    = "dc1"
  root_cert     = module.consul_certificate_authority
  vault_cluster = module.vault_cluster
  global_config = module.consul_global_config
  agent_ips     = local.all_consul_ips
  bucket_name   = "consul-bootstrap"
}

# @TODO Generate in datacenter and store in vault
module "consul_gossip_encryption" {
  source = "../../modules/consul/keygen"
}

module "consul_bootstrap" {
  source = "../../modules/consul/bootstrap"

  consul_host       = "consul-1.dock.local"
  aws_region        = local.aws_region
  aws_endpoint      = local.aws_endpoint
  aws_profile       = local.aws_profile
  bucket_name       = "consul-bootstrap"
  initial_run       = var.initial_setup
  host_ssh_username = "docker-connect"
}

module "consul-1" {
  source = "../../modules/consul/server"

  datacenter    = module.dc1
  vault_cluster = module.vault_cluster
  root_cert     = module.consul_certificate_authority
  hostname      = "consul-1"

  gossip_key = module.consul_gossip_encryption.secret

  consul_version = "1.15.3"

  initial_run = var.initial_setup

  docker_host     = "consul-1.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.71"
}

module "consul-2" {
  source = "../../modules/consul/server"

  datacenter    = module.dc1
  vault_cluster = module.vault_cluster
  root_cert     = module.consul_certificate_authority
  hostname      = "consul-2"

  gossip_key = module.consul_gossip_encryption.secret

  consul_version = "1.15.3"

  initial_run = var.initial_setup

  docker_host     = "consul-2.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.72"
}

module "consul-3" {
  source = "../../modules/consul/server"

  datacenter    = module.dc1
  vault_cluster = module.vault_cluster
  root_cert     = module.consul_certificate_authority
  hostname      = "consul-3"

  gossip_key = module.consul_gossip_encryption.secret

  consul_version = "1.15.3"

  initial_run = var.initial_setup

  docker_host     = "consul-3.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.73"
}

module "consul_static_tokens" {
  source = "../../modules/consul/static_tokens"

  vault_cluster = module.vault_cluster
  datacenter    = module.dc1
  bootstrap     = module.consul_bootstrap
  consul_servers = [
    module.consul-1,
    module.consul-2,
    module.consul-3
  ]
}

module "nomad_certificate_authority" {
  source = "../../modules/certificate_authority"

  domain_name   = local.domain_name
  subdomain     = "nomad"
  vault_cluster = module.vault_cluster
  description   = "Nomad CA"
  mount_name    = "nomad"
}

module "nomad_global" {
  source = "../../modules/nomad/region"

  region            = "global"
  root_cert         = module.nomad_certificate_authority
  vault_cluster     = module.vault_cluster
  nomad_server_ips  = local.all_nomad_server_ips
  consul_datacenter = module.dc1
}

module "nomad-1" {
  source = "../../modules/nomad/server"

  root_cert         = module.nomad_certificate_authority
  region            = module.nomad_global
  vault_cluster     = module.vault_cluster
  hostname          = "nomad-1"
  consul_root_cert  = module.consul_certificate_authority
  consul_datacenter = module.dc1
  consul_gossip_key = module.consul_gossip_encryption.secret
  consul_bootstrap  = module.consul_bootstrap
  vault_init        = module.vault_init

  initial_run = var.initial_setup

  nomad_version  = "1.5.6"
  consul_version = "1.15.2"

  docker_host     = "nomad-1.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.81"
}

module "nomad-2" {
  source = "../../modules/nomad/server"

  root_cert         = module.nomad_certificate_authority
  region            = module.nomad_global
  vault_cluster     = module.vault_cluster
  hostname          = "nomad-2"
  consul_root_cert  = module.consul_certificate_authority
  consul_datacenter = module.dc1
  consul_gossip_key = module.consul_gossip_encryption.secret
  consul_bootstrap  = module.consul_bootstrap
  vault_init        = module.vault_init

  initial_run = var.initial_setup

  nomad_version  = "1.5.6"
  consul_version = "1.15.2"

  docker_host     = "nomad-2.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.82"
}

module "nomad_bootstrap" {
  source = "../../modules/nomad/bootstrap"

  nomad_host   = module.nomad-1
  aws_region   = local.aws_region
  aws_endpoint = local.aws_endpoint
  aws_profile  = local.aws_profile
  bucket_name  = "nomad-bootstrap"
  initial_run  = var.initial_setup
}

module "nomad_static_tokens" {
  source = "../../modules/nomad/static_tokens"

  root_cert     = module.nomad_certificate_authority
  region        = module.nomad_global
  bootstrap     = module.nomad_bootstrap
  vault_cluster = module.vault_cluster
}

module "nomad_dc1" {
  source = "../../modules/nomad/datacenter"

  datacenter        = "dc1"
  root_cert         = module.nomad_certificate_authority
  region            = module.nomad_global
  vault_cluster     = module.vault_cluster
  nomad_client_ips  = local.all_nomad_client_ips
  consul_datacenter = module.dc1
}

module "nomad_nfs_dc1_service_role" {

  source = "../../modules/service_role"

  name = "nfs"

  nomad_bootstrap     = module.nomad_bootstrap
  nomad_region        = module.nomad_global
  nomad_datacenter    = module.nomad_dc1
  consul_root_cert    = module.consul_certificate_authority
  consul_datacenter   = module.dc1
  consul_bootstrap    = module.consul_bootstrap
  vault_cluster       = module.vault_cluster
  nomad_static_tokens = module.nomad_static_tokens
}

module "nomad_nfs_dc1" {
  source = "../../modules/nomad/nfs"

  nfs_server       = module.nfs_server.fqdn
  nfs_directory    = "/storage/dc1"
  service_role     = module.nomad_nfs_dc1_service_role
}

module "nomad-client-1" {
  source = "../../modules/nomad/client"

  root_cert         = module.nomad_certificate_authority
  region            = module.nomad_global
  vault_cluster     = module.vault_cluster
  hostname          = "nomad-client-1"
  consul_root_cert  = module.consul_certificate_authority
  consul_datacenter = module.dc1
  consul_gossip_key = module.consul_gossip_encryption.secret
  consul_bootstrap  = module.consul_bootstrap
  datacenter        = module.nomad_dc1

  nomad_version  = "1.5.6"
  consul_version = "1.15.2"

  docker_host     = "nomad-client-1.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.91"
}


module "traefik_service_role" {

  source = "../../modules/service_role"

  name = "traefik"

  nomad_bootstrap     = module.nomad_bootstrap
  nomad_region        = module.nomad_global
  nomad_datacenter    = module.nomad_dc1
  consul_root_cert    = module.consul_certificate_authority
  consul_datacenter   = module.dc1
  consul_bootstrap    = module.consul_bootstrap
  vault_cluster       = module.vault_cluster
  nomad_static_tokens = module.nomad_static_tokens

  additional_consul_services = ["metrics"]

  additional_consul_policy = <<EOF
agent_prefix "" {
  policy = "read"
}

node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "read"
}
EOF

  additional_vault_application_policy = <<EOF
# Allow access to read root CA
path "${module.consul_certificate_authority.pki_mount_path}/cert/ca"
{
  capabilities = ["read"]
}
EOF
}

module "traefik" {
  source = "../../modules/services/traefik"

  service_role = module.traefik_service_role
}

module "victoria_metrics" {
  source = "../../modules/victoria_metrics"

  hostname    = "mon-1"
  domain_name = local.domain_name

  vault_cluster     = module.vault_cluster
  consul_datacenter = module.dc1
  consul_gossip_key = module.consul_gossip_encryption.secret
  consul_bootstrap  = module.consul_bootstrap
  consul_root_cert  = module.consul_certificate_authority
  consul_version    = "1.15.2"

  docker_host     = "mon-1.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.52"
}


module "loki" {
  source = "../../modules/loki"

  hostname    = "mon-1"
  domain_name = local.domain_name

  docker_host     = "mon-1.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.52"
}

module "vector" {
  source = "../../modules/services/vector"

  nomad_bootstrap   = module.nomad_bootstrap
  nomad_region      = module.nomad_global
  nomad_datacenter  = module.nomad_dc1
  consul_root_cert  = module.consul_certificate_authority
  consul_datacenter = module.dc1
  consul_bootstrap  = module.consul_bootstrap
  vault_cluster     = module.vault_cluster
  traefik           = module.traefik
  loki              = module.loki
}

module "grafana" {
  source = "../../modules/grafana"

  hostname    = "mon-1"
  domain_name = local.domain_name

  docker_host     = "mon-1.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.52"
}

module "grafana_configure" {
  source = "../../modules/grafana/configure"

  grafana          = module.grafana
  loki             = module.loki
  victoria_metrics = module.victoria_metrics
}

