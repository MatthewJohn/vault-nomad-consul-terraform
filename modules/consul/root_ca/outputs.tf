output "domain_name" {
  description = "Consul domain of root CA"
  value       = var.domain
}

output "s3_bucket" {
  description = "S3 bucket name that holds CA certs"
  value       = aws_s3_bucket.root_ca_certs.bucket
}

output "s3_prefix" {
  description = "S3 prefix"
  value       = data.external.root_ca.result.bucket_prefix
}

output "s3_key_public_key" {
  description = "S3 key for public key"
  value       = data.external.root_ca.result.public_key
}

output "s3_key_private_key" {
  description = "S3 key for private key"
  value       = data.external.root_ca.result.private_key
}
