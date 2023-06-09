output "fqdn" {
  description = "FQDN of loki"
  value       = local.fqdn
}

output "endpoint" {
  description = "Loki endpoint"
  value       = "${local.fqdn}:${var.port}"
}