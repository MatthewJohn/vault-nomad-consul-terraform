resource "nomad_job" "terrareg" {
  jobspec = <<EOHCL
  
job "terrareg" {
  datacenters = ["${var.service_role.nomad.datacenter}"]

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
      name = "${var.service_role.name}"
      port = 5000
      tags = ["traefik-routing"]

      connect {
        sidecar_service {
          proxy {}
        }
      }
    }

    task "web" {
      driver = "docker"

      # config {
      #   image   = "fare-docker-reg.dock.studios:5000/terrareg:v2.68.3"
      #   ports   = ["http"]
      # }

      # TEMP
      config {
        image   = "busybox:1"
        command = "httpd"
        args    = ["-v", "-f", "-p", "8001", "-h", "/local"]
        ports   = ["http"]
      }

      template {
        data        = <<EOF
                        <h1>Hello, Nomad!</h1>
                        <ul>
                          <li>Task: {{env "NOMAD_TASK_NAME"}}</li>
                          <li>Group: {{env "NOMAD_GROUP_NAME"}}</li>
                          <li>Job: {{env "NOMAD_JOB_NAME"}}</li>
                          <li>Metadata value for foo: {{env "NOMAD_META_foo"}}</li>
                          <li>Currently running on port: 8001</li>
                        </ul>
                      EOF
        destination = "local/index.html"
      }
      # END TEMP

      vault {
        policies = ["${var.service_role.vault_application_policy}"]
      }

      template {
        data        = <<EOF
{{ with secret "${var.service_role.vault_secret_base_path}/terrareg" }}
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

  consul_token = data.vault_generic_secret.consul_token.data["token"]
  vault_token  = vault_token.role_token.client_token
}
