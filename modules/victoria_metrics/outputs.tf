output "fqdn" {
  description = "FQDN of victoriametrics"
  value       = local.fqdn
}

output "endpoint" {
  description = "Victoriametrics endpoint"
  value       = "${local.fqdn}:8428"
}