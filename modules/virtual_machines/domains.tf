
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


module "consul" {
  for_each = var.consul_hosts

  source  = "terraform-registry.dockstudios.co.uk/dockstudios/libvirt-virtual-machine/libvirt"
  version = ">= 0.0.6"

  name                       = each.key
  ip_address                 = each.value.ip_address
  ip_gateway                 = each.value.ip_gateway
  nameservers                = var.nameservers
  memory                     = 386
  disk_size                  = 4000
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
    "/consul",
    "/consul/config",
    "/consul/config/templates",
    "/consul/config/agent-certs",
    "/consul/vault",
    "/vault-agent-consul-template",
    "/vault-agent-consul-template/config.d",
    "/vault-agent-consul-template/ssl",
  ]
}


module "nomad" {
  for_each = var.nomad_server_hosts

  source  = "terraform-registry.dockstudios.co.uk/dockstudios/libvirt-virtual-machine/libvirt"
  version = ">= 0.0.6"

  name                       = each.key
  ip_address                 = each.value.ip_address
  ip_gateway                 = each.value.ip_gateway
  nameservers                = var.nameservers
  memory                     = 512
  disk_size                  = 5000
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
    "/nomad",
    "/nomad/config",
    "/nomad/config/templates",
    "/nomad/config/server-certs",
    "/nomad/config/consul-certs",
    "/nomad/vault",
    "/vault-agent-consul-template",
    "/vault-agent-consul-template/config.d",
    "/vault-agent-consul-template/ssl",

    # Consul agent directories
    "/consul",
    "/consul/config",
    "/consul/config/templates",
    "/consul/config/client-certs",
    "/consul/vault",
    "/consul-agent-vault-agent-consul-template",
    "/consul-agent-vault-agent-consul-template/config.d",
    "/consul-agent-vault-agent-consul-template/ssl",
  ]
}

