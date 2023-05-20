resource "vault_policy" "this" {
  name = var.policy_name

  policy = var.policy
}