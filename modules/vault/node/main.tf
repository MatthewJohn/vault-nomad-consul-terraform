module "vault_image" {
  source = "./image"

  vault_version = var.vault_version
  http_proxy    = var.http_proxy

  providers = {
    docker = docker.vault
  }
}

module "vault_container" {
  source = "./container"

  image                 = module.vault_image.image_id
  vault_subdomain       = var.vault_subdomain
  all_vault_hosts       = var.all_vault_hosts
  kms_key_id            = var.kms_key_id
  kms_backing_key_value = var.kms_backing_key_value

  vault_adm_pki_backend = var.vault_adm_pki_backend
  vault_adm_pki_role    = var.vault_adm_pki_role

  docker_host = var.docker_host

  providers = {
    docker          = docker.vault
    vault.vault-adm = vault.vault-adm
  }

  depends_on = [
    module.vault_image
  ]
}
