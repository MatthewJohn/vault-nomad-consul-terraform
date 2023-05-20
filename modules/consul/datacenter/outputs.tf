
output "name" {
  description = "Datacenter name"
  value = var.datacenter
}

output "domain" {
  description = "Datacenter domain"
  value = "${var.datacenter}.${var.consul_domain}"
}

output "pki_mount_path" {
  description = "PKI path"
  value = vault_mount.this.path
}
