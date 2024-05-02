locals {
  base_harbor_image_name = "${var.nomad_datacenter.name}-${var.service_name}"
}

resource "harbor_project" "this" {
  for_each = toset(concat([""], var.additional_tasks))

  name   = "${local.base_harbor_image_name}${each.value == "" ? "" : "-${each.value}"}"
  public = false

  vulnerability_scanning = true
  deployment_security    = "critical"
  cve_allowlist          = []

  force_destroy = false
  storage_quota = 10

  enable_content_trust        = false
  enable_content_trust_cosign = false
}

resource "harbor_immutable_tag_rule" "this" {
  for_each = harbor_project.this

  disabled      = false
  project_id    = each.value.id
  # repo_matching = "**"
  tag_matching  = "*"
  tag_excluding = "latest"
}

resource "random_password" "harbor" {
  length  = 38
  special = false
}

resource "harbor_robot_account" "system" {
  name        = "deployment-${var.nomad_datacenter.name}-${var.service_name}"
  description = "Robot deployment account for ${var.service_name}"
  level       = "system"
  secret      = random_password.harbor.result

  dynamic "permissions" {
    for_each = harbor_project.this

    content {
      access {
        action   = "push"
        resource = "repository"
      }
      kind      = "project"
      namespace = permissions.value.name
    }
  }
}