resource "vault_consul_secret_backend" "test" {
  path        = "consul-${var.name}"
  description = "Manages the Consul backend"
  address     = "127.0.0.1:8500"
  token       = "4240861b-ce3d-8530-115a-521ff070dd29"
}