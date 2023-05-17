
module "vault-1" {
  source = "./domain"

  name       = "vault-1"
  ip_address = "192.168.122.60"
  ip_gateway = "192.168.122.1"
  nameservers = var.nameservers
  memory     = 256
  disk_size  = 1000
  base_disk_path = var.base_disk_path
  hypervisor_hostname = var.hypervisor_hostname
  hypervisor_username = var.hypervisor_username
}
