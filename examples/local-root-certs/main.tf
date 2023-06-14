module "this" {
  source = "../../modules/vault/root_certs"

  root_cn      = "dock.local"
  organisation = "DS Local"
}
