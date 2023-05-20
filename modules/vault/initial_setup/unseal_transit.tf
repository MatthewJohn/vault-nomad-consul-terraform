resource "vault_mount" "transit-unseal" {
  path                      = "autounseal"
  type                      = "transit"
  description               = "Vault unseal transit"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_policy" "transit-unseal" {
  name = "autounseal"

  policy = <<EOT
path "transit/encrypt/autounseal" {
   capabilities = [ "update" ]
}

path "transit/decrypt/autounseal" {
   capabilities = [ "update" ]
}
EOT
}

resource "vault_token" "transit-unseal" {
  role_name = "app"

  policies = ["policy1", "policy2"]

  renewable = true
  ttl = "24h"

  renew_min_lease = 43200
  renew_increment = 86400

  metadata = {
    "purpose" = "service-account"
  }
}
