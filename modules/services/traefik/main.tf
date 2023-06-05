resource "nomad_job" "traefik" {
  jobspec = <<EOHCL
job "traefik" {
  datacenters = ["${var.nomad_datacenter.name}"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port "http"{
         static = 80
      }
      port "https"{
         static = 443
      }
      port "admin"{
         static = 8080
      }
    }

    service {
      name = "${local.consul_service_name}"
      port = "http"
    }

    task "server" {
      driver = "docker"

      vault {
        policies = ["${vault_policy.traefik.name}"]

        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      config {
        image = "traefik:v2.10.1"
        ports = ["admin", "http"]
        args = [
          "--api.dashboard=true",
          "--api.insecure=true", ### For Test only, please do not use that in production
          "--entrypoints.web.address=:$${NOMAD_PORT_http}",
          "--entrypoints.websecure.address=:$${NOMAD_PORT_https}",
          "--entrypoints.traefik.address=:$${NOMAD_PORT_admin}",
          #"--providers.nomad=true",
          #"--providers.nomad.endpoint.address=${var.nomad_region.address}"
          # Make the communication secure by default
          "--providers.consulcatalog.connectByDefault=true",
          "--providers.consulcatalog.exposedByDefault=true",
          # "--entrypoints.http=true",
          # "--entrypoints.http.address=:8080",
          "--providers.consulcatalog.servicename=${local.consul_service_name}",
          "--providers.consulcatalog.prefix=traefik",
          "--providers.consulcatalog.connectAware=true",

          # Automatically configured by Nomad through CONSUL_* environment variables
          # as long as client consul.share_ssl is enabled
          "--providers.consulcatalog.endpoint.address=${var.consul_datacenter.address_wo_protocol}",
          "--providers.consulcatalog.endpoint.scheme=https",
          "--providers.consulcatalog.endpoint.datacenter=${var.consul_datacenter.name}",
          "--providers.consulcatalog.endpoint.tls.ca=/consul/ca.crt",
          "--providers.consulcatalog.endpoint.token=$${NOMAD_TOKEN}",
          "--providers.consulcatalog.constraints=Tag(`traefik-routing`)",
          "--providers.consulcatalog.defaultRule=Host(`{{ .Name }}.service.${var.nomad_datacenter.common_name}`)"
        ]

        volumes = [
          "secrets/consul_ca.crt:/consul/ca.crt"
        ]
      }


      template {
        data = <<EOF
{{ with secret "${var.consul_root_cert.pki_mount_path}/cert/ca" }}
{{ .Data.certificate }}
{{ end }}
EOF
        destination = "secrets/consul_ca.crt"
      }

      template {
        data = <<EOH
{{ with secret "${var.consul_datacenter.consul_engine_mount_path}/creds/${vault_consul_secret_backend_role.traefik.name}" }}
NOMAD_TOKEN="{{ .Data.token }}"
{{end}}
EOH
        destination = "secrets/nomad.env"
        env         = true
      }
    }
  }
}
EOHCL
}