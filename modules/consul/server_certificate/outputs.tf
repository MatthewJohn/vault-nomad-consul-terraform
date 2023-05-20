
output "s3_bucket" {
  description = "S3 bucket name that holds CA certs"
  value       = var.root_ca.s3_bucket
}

output "s3_prefix" {
  description = "S3 prefix"
  value       = var.root_ca.s3_prefix
}

output "s3_key_public_key" {
  description = "S3 key for public key"
  value       = data.external.generate_cert.result.public_key
}

output "s3_key_private_key" {
  description = "S3 key for private key"
  value       = data.external.generate_cert.result.private_key
}

