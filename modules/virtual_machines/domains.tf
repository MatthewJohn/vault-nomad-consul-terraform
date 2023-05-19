
module "vault" {
  for_each = var.vault_hosts

  source  = "terraform-registry.dockstudios.co.uk/dockstudios/libvirt-virtual-machine/libvirt"
  version = ">= 0.0.6"

  name                       = each.key
  ip_address                 = each.value.ip_address
  ip_gateway                 = each.value.ip_gateway
  nameservers                = var.nameservers
  memory                     = 386
  disk_size                  = 3000
  base_disk_path             = var.base_disk_path
  hypervisor_hostname        = var.hypervisor_hostname
  hypervisor_username        = var.hypervisor_username
  docker_ssh_key             = var.docker_ssh_key
  domain_name                = var.domain_name
  network_bridge             = each.value.network_bridge
  additional_dns_hostnames   = each.value.additional_dns_hostnames
  hosts_entries              = var.hosts_entries
  install_docker             = true

  create_directories = [
    "/vault",
    "/vault/config.d",
    "/kms",
    "/kms/init",
  ]
}

