module "this" {
  source = "../../modules/root_certs"

  root_cn = "dock.local"
  organisation = "DS Local"
}