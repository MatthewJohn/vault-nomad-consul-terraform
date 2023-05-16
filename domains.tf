
module "vault-1" {
  source = "./domain"

  name       = "vault-1"
  ip_address = "192.168.0.60"
  memory     = "128"
}
