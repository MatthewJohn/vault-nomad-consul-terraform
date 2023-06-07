resource "nomad_job" "terrareg" {
  jobspec = <<EOHCL
  
job "terrareg" {
  datacenters = ["${var.nomad_datacenter.name}"]

  group "web" {

    count = 1
    
    network {
      mode = "bridge"
    }

    volume "terrareg" {
      type            = "csi"
      source          = "terrareg"
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    service {
      name = "terrareg"
      port = 5000
      tags = ["traefik-routing"]

      connect {
        sidecar_service {}
      }
    }

    task "web" {
      driver = "docker"

      config {
        image   = "fare-docker-reg.dock.studios:5000/terrareg:v2.68.3"
        ports   = ["http"]
      }

      vault {
        policies = ["${vault_policy.terrareg.name}"]
      }

      template {
        data        = <<EOF
{{ with secret "service_secrets_kv/${var.nomad_region.name}/${var.nomad_datacenter.name}/terrareg" }}
MIGRATE_DATABASE=True
DOMAIN_NAME=terrareg.${var.traefik.service_domain}
PUBLIC_URL=https://terrareg.${var.traefik.service_domain}
ENABLE_ACCESS_CONTROLS=false
ADMIN_AUTHENTICATION_TOKEN={{.Data.data.admin_password}}
SECRET_KEY={{.Data.data.secret_key}}
DATABASE_URL=sqlite:///database/db.sqlite
{{ end }}
EOF
        destination = "$${NOMAD_SECRETS_DIR}/terrareg.env"
        env         = true
      }

      volume_mount {
        volume      = "terrareg"
        destination = "/app/database"
      }

      resources {
        cpu    = 50
        memory = 128
      }
    }
  }
}
EOHCL
}
