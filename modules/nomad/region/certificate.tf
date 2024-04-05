
resource "vault_pki_secret_backend_role" "this" {
  backend = var.root_cert.pki_mount_path
  name    = "nomad-${var.region}"

  max_ttl          = (720 * 60 * 60) # "720h"
  generate_lease   = true
  allowed_domains  = [local.common_name, local.nomad_verify_domain]
  allow_subdomains = true
}
