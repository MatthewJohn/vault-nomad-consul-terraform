
module "vault_token" {
  source = "../vault/policy_token"

  policy_name = "victoria-metrics"

  policy = <<EOF
path "/sys/metrics" {
  capabilities = ["read"]
}
EOF
}
