output "key_id" {
  description = "KMS Key ID"
  value       = local.kms_key_id
}

output "backing_key_value" {
  description = "Backing key value for KMS"
  value = random_id.kms_backing_key.hex
}
