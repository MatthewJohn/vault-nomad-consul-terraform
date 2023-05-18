
module "vault-1" {
  source  = "terraform-registry.dockstudios.co.uk/dockstudios/libvirt-virtual-machine/libvirt"
  version = ">= 0.0.4"

  name                = "vault-1"
  ip_address          = "192.168.122.60"
  ip_gateway          = "192.168.122.1"
  nameservers         = var.nameservers
  memory              = 256
  disk_size           = 3000
  base_disk_path      = var.base_disk_path
  hypervisor_hostname = var.hypervisor_hostname
  hypervisor_username = var.hypervisor_username
  docker_ssh_key      = var.docker_ssh_key
  domain_name         = var.domain_name
  network_bridge      = "virbr0"

  create_directories = [
    "/vault",
    "/vault/config.d"
  ]
}

