locals {
  base_harbor_image_name = local.name_with_dc
}

resource "harbor_project" "this" {
  for_each = toset([""])

  name   = local.base_harbor_image_name
  public = var.public_repo

  vulnerability_scanning = true
  deployment_security    = "critical"
  cve_allowlist          = var.allowed_cves

  force_destroy = false
  storage_quota = 10

  enable_content_trust        = false
  enable_content_trust_cosign = false
}

resource "harbor_immutable_tag_rule" "this" {
  for_each = harbor_project.this

  disabled      = false
  project_id    = each.value.id
  repo_matching = "**"
  tag_excluding = "*latest*"
}

resource "random_password" "harbor" {
  length  = 38
  special = false
}

resource "harbor_robot_account" "system" {
  name        = "deployment-${local.base_harbor_image_name}"
  description = "Robot deployment account for ${var.job_name}"
  level       = "system"
  secret      = random_password.harbor.result

  dynamic "permissions" {
    for_each = harbor_project.this

    content {
      access {
        action   = "push"
        resource = "repository"
      }
      access {
        action   = "pull"
        resource = "repository"
      }
      kind      = "project"
      namespace = permissions.value.name
    }
  }
}

resource "random_password" "nomad_harbor" {
  length  = 38
  special = false
}

resource "harbor_robot_account" "nomad" {
  name        = "nomad-${local.base_harbor_image_name}"
  description = "Robot deployment account for ${var.job_name}"
  level       = "system"
  secret      = random_password.nomad_harbor.result

  dynamic "permissions" {
    for_each = harbor_project.this

    content {
      access {
        action   = "pull"
        resource = "repository"
      }
      kind      = "project"
      namespace = permissions.value.name
    }
  }
}