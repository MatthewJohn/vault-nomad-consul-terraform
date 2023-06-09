resource "vault_token" "this" {
  policies = [vault_policy.this.name]

  ttl = 356 * 24 * 60 * 60

  metadata = {
    "purpose" = "${var.policy_name}"
  }
}
