locals {
  common_name         = "${var.datacenter}.${var.region.common_name}"
  nomad_verify_domain = "${var.region.name}.nomad"
}

resource "vault_pki_secret_backend_role" "client" {
  backend = var.region.pki_mount_path
  name    = "nomad-client-${var.region.name}-${var.datacenter}"

  max_ttl        = (720 * 60 * 60) # "720h"
  generate_lease = true
  allowed_domains = [
    # Allow for:
    # server.dc.region.nomad
    # server.dc.region.nomad.rootdomain
    # hostname.dc.region.name.rootdomain
    # localhost
    local.common_name,
    local.nomad_verify_domain
  ]
  allow_subdomains = true
  allow_localhost  = true
  allow_ip_sans    = true
}
