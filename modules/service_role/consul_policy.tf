# Consul policy for deployment
resource "consul_acl_policy" "deployment" {
  count = local.enable_nomad_integration ? 1 : 0

  name = "nomad-deployment-job-${var.nomad_region.name}-${var.nomad_datacenter.name}-${var.job_name}"

  rules = <<-RULE
# Allow writing the services that the service will provide
# and modify intentions
%{for service, service_config in values(local.consul_services)}
service "${service_config.name}"
{
  policy = "write"
  intentions = "write"
}
%{endfor}
RULE
}

resource "vault_consul_secret_backend_role" "deployment" {
  count = local.enable_nomad_integration ? 1 : 0

  name    = consul_acl_policy.deployment[count.index].name
  backend = var.consul_datacenter.consul_engine_mount_path

  consul_policies = [
    consul_acl_policy.deployment[count.index].name
  ]
}

# Override consul policy for tasks
resource "consul_acl_policy" "tasks" {
  for_each = {
    for task_name, task_config in var.tasks :
    task_name => task_config
    if task_config.custom_consul_policy != null
  }

  name = "${local.base_full_name}-${each.key}"

  rules = each.value.custom_consul_policy
}

resource "consul_acl_role" "task" {
  for_each = {
    for task_name, task_config in var.tasks :
    task_name => task_config
    if task_config.custom_consul_policy != null
  }

  name = consul_acl_policy.tasks[each.key].name
  description = "Custom workload identity role for nomad ${consul_acl_policy.tasks[each.key].name}"
  policies = [
    var.nomad_datacenter.default_workload_consul_policy,
    consul_acl_policy.tasks[each.key].name,
  ]
}

resource "consul_acl_binding_rule" "task" {
  for_each = {
    for task_name, task_config in var.tasks :
    task_name => task_config
    if task_config.custom_consul_policy != null
  }

  auth_method = var.nomad_datacenter.consul_auth_method
  description = "Binding rule for tasks registered from Nomad"
  selector    = "\"nomad_service\" not in value and value.nomad_job_id == \"${var.job_name}\" and value.nomad_task == \"${each.key}\""
  bind_type   = "role"
  bind_name   = consul_acl_role.task[each.key].name
}