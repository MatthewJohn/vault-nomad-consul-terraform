
locals {
  freeipa_admin = "admin"
  freeipa_password = "password"
}

module "freeipa_initial_setup" {
  source = "./freeipa"

  # Set to 1 for initial setup
  count = 0

  initial_setup    = true
  freeipa_password = local.freeipa_password
}

module "freeipa" {
  source = "./freeipa"

  freeipa_password = local.freeipa_password
}

resource "libvirt_pool" "local-disks" {
  name = "local-disks"
  type = "dir"
  path = "/vm-disks"
}

module "this" {
  source = "../../"

  base_disk_path = "/vm-disks"
  base_image_path = "/vm-disks"
  hypervisor_hostname = "localhost"
  hypervisor_username = "matthew"
  nameservers = [module.freeipa.ip_address]
}


provider "docker" {
  alias = "local"
}

provider "libvirt" {
  uri = "qemu:///system"

  alias = "vm_host"
}
