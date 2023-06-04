output "fqdn" {
  description = "FQDN of the NFS server"
  value       = "${var.hostname}.${var.domain_name}"
}