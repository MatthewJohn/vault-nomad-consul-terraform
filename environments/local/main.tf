
locals {
  freeipa_admin    = "admin"
  freeipa_password = "password"
  domain_name      = "dock.local"
  docker_username  = "docker-connect"
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
}

locals {
  all_vault_hosts    = ["vault-1", "vault-2"]
  all_vault_host_ips = ["192.168.122.60", "192.168.122.61"]
}

module "vault_init" {
  source = "../../modules/vault_init"

  # vault-1 IP
  vault_host        = "vault-1.dock.local"
  aws_region        = "eu-east-1"
  aws_endpoint      = "http://s3.dock.local:9000"
  aws_profile       = "dockstudios-terraform"
  bucket_name       = "vault-unseal"
  initial_run       = var.initial_setup
  host_ssh_username = "docker-connect"
}

module "vault_cluster" {
  source = "../../modules/vault_cluster"

  domain_name  = local.domain_name
  ip_addresses = local.all_vault_host_ips
}

module "vault-1" {
  source = "../../modules/vault_node"

  domain_name     = local.domain_name
  hostname        = "vault-1"
  all_vault_hosts = local.all_vault_hosts

  docker_host     = "vault-1.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.60"

  # Use this node as initial primary
  initial_primary = var.initial_setup
}

module "vault-2" {
  source = "../../modules/vault_node"

  domain_name     = local.domain_name
  hostname        = "vault-2"
  all_vault_hosts = local.all_vault_hosts

  docker_host     = "vault-2.${local.domain_name}"
  docker_username = local.docker_username
  docker_ip       = "192.168.122.61"
}


provider "docker" {
  alias = "local"
}

provider "freeipa" {
  host     = "freeipa.dock.local"
  username = local.freeipa_admin
  password = local.freeipa_password
  insecure = true
}

provider "libvirt" {
  uri = "qemu:///system"

  alias = "vm_host"
}
