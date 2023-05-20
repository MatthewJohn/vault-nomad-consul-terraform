module "admin_token" {
  source = "../admin_token"

  admin_policy_name = var.admin_policy_name
  admin_role_name   = var.admin_role_name

  root_token = var.root_token

  vault_cluster = {
    ca_cert_file = var.ca_cert_file
    address      = local.cluster_address
  }
}
