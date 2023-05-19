
module "s3" {
  source  = "terraform-registry.dockstudios.co.uk/dockstudios/local-s3/docker"
  version = "0.0.1"

  domain_name = local.domain_name
  root_username = "root"
  root_password = "password"
}


module "s3_configure" {
  #source  = "terraform-registry.dockstudios.co.uk/dockstudios/local-s3/docker//modules/configure"
  #version = "0.0.1"
  source = "../../../terraform-modules/local-s3/modules/configure"

  domain_name = local.domain_name
  root_username = module.s3.root_username
  root_password = module.s3.root_password

  allowed_terraform_buckets_read_only = [
    "intermediate-ca-certs",
    "root-ca-certs"
  ]
  allowed_terraform_buckets_full_access = [
    "vault-unseal"
  ]
}
