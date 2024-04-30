locals {
  base_harbor_image_name = "${var.nomad_datacenter.name}-${var.service_name}"
}

resource "harbor_project" "this" {
  for_each = toset(concat([""], var.additional_consul_services))

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