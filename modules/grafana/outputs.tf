output "fqdn" {
  description = "FQDN of victoriametrics"
  value       = local.fqdn
}

output "endpoint" {
  description = "Victoriametrics endpoint"
  value       = "${local.fqdn}:3000"
}

output "admin_username" {
  description = "Admin username"
  value       = "admin"
}

output "admin_password" {
  description = "Admin passsword"
  value       = random_password.admin_password.result
}
