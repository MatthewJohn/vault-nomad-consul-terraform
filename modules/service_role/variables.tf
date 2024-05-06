variable "job_name" {
  description = "Name of job"
  type        = string
}

variable "gitlab_project_path" {
  description = "Gitlab project path"
  type        = string
}

variable "nomad_namespace" {
  description = "Nomad namespace for the service to be deployed to"
  type        = string
  default     = "default"
}

variable "nomad_datacenter" {
  description = "Nomad datacenter"
  type = object({
    name                              = string
    common_name                       = string
    client_dns                        = string
    vault_jwt_path                    = string
    default_workload_vault_policy     = string
    default_workload_vault_role       = string
    workload_identity_vault_aud       = list(string)
    consul_auth_method                = string
    default_workload_consul_policy    = string
    default_workload_consul_task_role = string
    workload_identity_consul_aud      = list(string)
  })
}

variable "nomad_region" {
  description = "Nomad region"
  type = object({
    name                 = string
    address              = string
    root_cert_public_key = string
    approle_mount_path   = string
  })
}

variable "nomad_static_tokens" {
  description = "Nomad static tokens object"
  type = object({
    nomad_engine_mount_path = string
  })
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file                         = string
    ca_cert                              = string
    address                              = string
    consul_static_mount_path             = string
    service_secrets_mount_path           = string
    service_deployment_mount_path        = string
    terraform_aws_credential_secret_path = string
    gitlab_jwt_auth_backend_path         = string
  })
}

variable "consul_root_cert" {
  description = "Consul root certificate authority"
  type = object({
    pki_mount_path = string
    public_key     = string
    domain_name    = string
  })
}

variable "consul_datacenter" {
  description = "Consul datacenter"
  type = object({
    name                     = string
    address                  = string
    address_wo_protocol      = string
    consul_engine_mount_path = string
    root_cert_public_key     = string
    app_service_domain       = string
  })
}

variable "tasks" {
  description = "List of tasks with overrides, if required"
  type = map(object({
    custom_vault_policy = optional(string, null)
    custom_consul_policy = optional(string, null)
  }))
}

variable "additional_vault_deployment_policy" {
  description = "Additional statements for vault deployment policy"
  type        = string
  default     = null
}

variable "additional_nomad_policy" {
  description = "Additional statements for the nomad policy"
  type        = string
  default     = ""
}

variable "additional_nomad_namespace_capabilities" {
  description = "List of additional capabilities for nomad namespace permissions"
  type        = list(string)
  default     = []
}

variable "allow_volume_creation" {
  description = "Whether to allow service to create/mount volumes"
  type        = bool
  default     = false
}

variable "public_repo" {
  description = "Whether harbor repo is public"
  type        = bool
  default     = false
}

variable "harbor_hostname" {
  description = "Harbor hostnmae"
  type        = string
}

locals {
  base_full_name = var.nomad_datacenter != null ? "nomad-job-${var.nomad_region.name}-${var.nomad_datacenter.name}-${var.job_name}" : var.job_name
  base_consul_service = var.nomad_datacenter != null ? "nomad-job-${var.nomad_datacenter.name}-${var.job_name}" : var.job_name
  name_with_dc = var.nomad_datacenter != null ? "${var.nomad_datacenter.name}-${var.job_name}" : var.job_name
  enable_nomad_integration = var.nomad_datacenter != null
}