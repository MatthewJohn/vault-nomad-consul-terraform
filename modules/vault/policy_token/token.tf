resource "vault_token" "this" {
  policies = [vault_policy.this.name]

  renewable = true

  renew_min_lease = 43200
  renew_increment = 86400

  metadata = {
    "purpose" = "${var.policy_name}"
  }
}
