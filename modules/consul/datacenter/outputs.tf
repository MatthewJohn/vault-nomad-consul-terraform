
output "name" {
  description = "Datacenter name"
  value = var.datacenter
}

output "common_name" {
  description = "Common name"
  value = local.common_name
}

output "pki_mount_path" {
  description = "PKI path"
  value = vault_mount.this.path
}
