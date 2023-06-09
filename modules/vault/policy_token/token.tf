resource "vault_token" "this" {
  policies = [vault_policy.this.name]

  ttl = "0"

  metadata = {
    "purpose" = "${var.policy_name}"
  }
}
