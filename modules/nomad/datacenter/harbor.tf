module "harbor_account" {
  source = "../../harbor_account"

  name            = "nomad-client-${var.region.name}-${var.datacenter}"
  vault_cluster   = var.vault_cluster
  harbor_projects = var.harbor_projects
  harbor_hostname = var.harbor_hostname
}
