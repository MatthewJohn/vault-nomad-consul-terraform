resource "nomad_job" "traefik" {
  jobspec = <<EOHCL
job "${var.service_role.name}" {
  datacenters = ["${var.service_role.nomad.datacenter}"]
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
      port "metrics_envoy" {
        to = 9102
      }
      port "metrics" {
        to = 8082
      }

      mode = "bridge"
    }

    service {
      name = "${var.service_role.consul_service_name}"
      port = "http"

      meta {
        # Tag for prometheus scrape-targeting via consul (envoy)
        metrics_port_envoy = "$${NOMAD_HOST_PORT_metrics_envoy}"
      }

      connect {
        sidecar_service {
          proxy {
            config {
              # Expose metrics for prometheus (envoy)
              envoy_prometheus_bind_addr = "0.0.0.0:9102"
            }
          }
        }

        sidecar_task {
          resources {
            cpu    = 50
            memory = 48
          }
        }
      }
    }

    service {
      name = "traefik-metrics"
      port = "metrics"
    }

    ephemeral_disk {
      size = 105
    }

    task "server" {
      driver = "docker"

      vault {
        policies = ["${var.service_role.vault_application_policy}"]

        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      config {
        image = "traefik:v2.10.1"
        ports = ["admin", "http", "metrics"]
        args = [
          "--api.dashboard=true",
          "--api.insecure=true", ### For Test only, please do not use that in production
          "--entrypoints.web.address=:$${NOMAD_PORT_http}",
          "--entrypoints.websecure.address=:$${NOMAD_PORT_https}",
          "--entrypoints.traefik.address=:$${NOMAD_PORT_admin}",
          #"--providers.nomad=true",
          #"--providers.nomad.endpoint.address=${var.service_role.nomad.address}"
          # Make the communication secure by default
          "--providers.consulcatalog.connectByDefault=true",
          "--providers.consulcatalog.exposedByDefault=true",
          # "--entrypoints.http=true",
          # "--entrypoints.http.address=:8080",
          "--providers.consulcatalog.servicename=${var.service_role.consul_service_name}",
          "--providers.consulcatalog.prefix=traefik",
          "--providers.consulcatalog.connectAware=true",

          # Prometheus metrics
          "--metrics.prometheus=true",
          "--entryPoints.metrics.address=:8082",
          "--metrics.prometheus.entryPoint=metrics",

          # Automatically configured by Nomad through CONSUL_* environment variables
          # as long as client consul.share_ssl is enabled
          "--providers.consulcatalog.endpoint.address=${var.service_role.consul.address_wo_protocol}",
          "--providers.consulcatalog.endpoint.scheme=https",
          "--providers.consulcatalog.endpoint.datacenter=${var.service_role.consul.datacenter}",
          "--providers.consulcatalog.endpoint.tls.ca=/consul/ca.crt",
          "--providers.consulcatalog.endpoint.token=$${CONSUL_TOKEN}",
          "--providers.consulcatalog.constraints=Tag(`traefik-routing`)",
          "--providers.consulcatalog.defaultRule=Host(`{{ .Name }}.${local.service_domain}`)"
        ]

        volumes = [
          "secrets/consul_ca.crt:/consul/ca.crt"
        ]
      }

      template {
        data = <<EOF
{{ with secret "${var.service_role.consul.root_cert_pki_mount_path}/cert/ca" }}
{{ .Data.certificate }}
{{ end }}
EOF
        destination = "secrets/consul_ca.crt"
      }

      template {
        data = <<EOH
{{ with secret "${var.service_role.vault_consul_engine_path}/creds/${var.service_role.vault_consul_role_name}" }}
CONSUL_TOKEN="{{ .Data.token }}"
{{end}}
EOH
        destination = "secrets/consul.env"
        env         = true
      }

      resources {
        cpu    = ${var.cpu}
        memory = ${var.memory}
      }
    }
  }
}
EOHCL

  vault_token = vault_token.role_token.client_token
  consul_token = data.vault_generic_secret.consul_token.data["token"]
}
