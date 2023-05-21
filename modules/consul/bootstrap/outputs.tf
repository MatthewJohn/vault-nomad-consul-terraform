
output "consul_unseal_bucket" {
  description = "Consul unseal s3 bucket"
  value       = aws_s3_bucket.consul_unseal.id
}

output "token" {
  description = "Consul bootstrap token"
  value       = data.external.init_consul.result.token
}
