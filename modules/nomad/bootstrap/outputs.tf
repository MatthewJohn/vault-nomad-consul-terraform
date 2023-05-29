
output "nomad_unseal_bucket" {
  description = "Consul unseal s3 bucket"
  value       = aws_s3_bucket.nomad_unseal.id
}

output "token" {
  description = "Consul bootstrap token"
  value       = data.external.init_nomad.result.token
}
