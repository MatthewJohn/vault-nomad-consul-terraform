# Store secret values back into vault admin to be able to consume in applications
resource "vault_kv_secret_v2" "secrets" {
  mount               = var.vault_cluster.service_deployment_mount_path
  name                = "konvad/services/${var.nomad_region.name}/${var.nomad_datacenter.name}/${var.service_name}"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      name                                = var.service_name
      consul_service_name                 = local.consul_service_name
      consul_policy_name                  = consul_acl_policy.this.name
      vault_consul_role_name              = vault_consul_secret_backend_role.this.name
      vault_consul_engine_path            = var.consul_datacenter.consul_engine_mount_path
      vault_nomad_role_name               = vault_nomad_secret_role.this.role
      vault_nomad_engine_path             = var.nomad_static_tokens.nomad_engine_mount_path
      vault_approle_deployment_role_id    = vault_approle_auth_backend_role.terraform.role_id
      vault_approle_deployment_secret_id  = vault_approle_auth_backend_role_secret_id.terraform.secret_id
      vault_approle_deployment_path       = var.nomad_region.approle_mount_path
      vault_approle_deployment_login_path = "auth/${var.nomad_region.approle_mount_path}/login"
      vault_submit_role_name              = vault_token_auth_backend_role.nomad.role_name
      # Secret engine
      vault_deployment_secret_engine_path = var.vault_cluster.service_deployment_mount_path
      vault_secret_engine_path            = var.vault_cluster.service_secrets_mount_path
      # Secret Path within secret mount
      vault_secret_path = local.vault_secret_path
      # Secret Path with mount
      vault_secret_base_path = local.vault_secret_base_path
      # Secret path with mount and 'data'
      vault_secret_base_data_path = local.vault_secret_base_data_path
      vault_deploy_policy         = vault_policy.terraform_policy.name
      vault_nomad_policy          = vault_policy.nomad_policy.name
      vault_application_policy    = vault_policy.application_policy.name
      vault = {
        ca_cert = var.vault_cluster.ca_cert
        address = var.vault_cluster.address
      }
      consul = {
        datacenter               = var.consul_datacenter.name
        address                  = var.consul_datacenter.address
        app_service_domain       = var.consul_datacenter.app_service_domain
        address_wo_protocol      = var.consul_datacenter.address_wo_protocol
        root_cert_public_key     = var.consul_datacenter.root_cert_public_key
        root_cert_pki_mount_path = var.consul_root_cert.pki_mount_path
      }
      nomad = {
        address                = var.nomad_region.address
        root_cert_public_key   = var.nomad_region.root_cert_public_key
        region                 = var.nomad_region.name
        datacenter             = var.nomad_datacenter.name
        datacenter_common_name = var.nomad_datacenter.common_name
        datacenter_client_dns  = var.nomad_datacenter.client_dns
        root_domain_name       = var.consul_root_cert.domain_name
        namespace              = var.nomad_namespace
      }
    }
  )
}
