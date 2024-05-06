# Store secret values back into vault admin to be able to consume in applications
resource "vault_kv_secret_v2" "secrets" {
  mount               = var.vault_cluster.service_deployment_mount_path
  name                = local.deployment_secret_path
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      name                                = var.job_name
      base_consul_service                 = local.base_consul_service
      consul_policy_name                  = try(consul_acl_policy.deployment[0].name, null)
      vault_consul_role_name              = try(vault_consul_secret_backend_role.deployment[0].name, null)
      vault_consul_engine_path            = var.consul_datacenter.consul_engine_mount_path
      vault_nomad_role_name               = try(vault_nomad_secret_role.deployment[0].role, null)
      vault_nomad_engine_path             = try(var.nomad_static_tokens.nomad_engine_mount_path, null)
      # Secret engine
      common_secrets                      = module.common_service_secret_path
      deployment_secrets                  = module.deployment_secret_path
      vault_deploy_policy                 = vault_policy.terraform_policy.name
      vault = {
        ca_cert = var.vault_cluster.ca_cert
        address = var.vault_cluster.address
      }
      tasks = {
        for task, task_config in var.tasks :
        task => {
          vault_aud      = var.nomad_datacenter.workload_identity_vault_aud
          vault_role     = try(vault_jwt_auth_backend_role.default_workload_identity[task].role_name, var.nomad_datacenter.default_workload_vault_role)
          vault_policies = try(vault_jwt_auth_backend_role.default_workload_identity[task].token_policies, [var.nomad_datacenter.default_workload_vault_policy])
          consul_aud     = var.nomad_datacenter.workload_identity_consul_aud
          consul_role    = try(consul_acl_role.task[task].name, var.nomad_datacenter.default_workload_consul_task_role)
          secrets        = module.task_service_secret_path[task]
        }
      }
      consul = {
        datacenter               = var.consul_datacenter.name
        address                  = var.consul_datacenter.address
        app_service_domain       = var.consul_datacenter.app_service_domain
        address_wo_protocol      = var.consul_datacenter.address_wo_protocol
        root_cert_public_key     = var.consul_datacenter.root_cert_public_key
        root_cert_pki_mount_path = var.consul_root_cert.pki_mount_path
      }
      nomad = local.enable_nomad_integration ? {
        address                = var.nomad_region.address
        root_cert_public_key   = var.nomad_region.root_cert_public_key
        region                 = var.nomad_region.name
        datacenter             = var.nomad_datacenter.name
        datacenter_common_name = var.nomad_datacenter.common_name
        datacenter_client_dns  = var.nomad_datacenter.client_dns
        root_domain_name       = var.consul_root_cert.domain_name
        namespace              = var.nomad_namespace
      } : {}
      docker_registry = {
        project  = local.base_harbor_image_name
        registry = var.harbor_hostname
        username = harbor_robot_account.system.full_name
        password = random_password.harbor.result
      }
    }
  )
}
