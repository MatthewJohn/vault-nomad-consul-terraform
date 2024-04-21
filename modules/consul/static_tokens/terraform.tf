resource "consul_acl_policy" "terraform" {
  name = "terraform-${var.datacenter.name}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
policy = "write"
acl = "write"
EOF
}

resource "vault_consul_secret_backend_role" "terraform" {
  name    = "terraform"
  backend = vault_consul_secret_backend.this.path

  consul_policies = [
    consul_acl_policy.terraform.name
  ]
}
