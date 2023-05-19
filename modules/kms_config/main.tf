
resource "random_id" "kms_key_id" {
  # Generates 32 hex characters
  byte_length = 16
}

resource "random_id" "kms_backing_key" {
  # Generates 64 hex characters
  byte_length = 32
}

locals {

  # Generate KMS key ID, splitting up random value
  kms_key_id = join(
    "-",
    [
      substr(random_id.kms_key_id.hex, 0, 8),
      substr(random_id.kms_key_id.hex, 8, 4),
      substr(random_id.kms_key_id.hex, 12, 4),
      substr(random_id.kms_key_id.hex, 16, 4),
      substr(random_id.kms_key_id.hex, 20, 12)
    ]
  )
}
