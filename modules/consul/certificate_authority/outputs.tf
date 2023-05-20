output "pki_mount_path" {
  description = "PKI path"
  value = vault_mount.consul_pki.path
}