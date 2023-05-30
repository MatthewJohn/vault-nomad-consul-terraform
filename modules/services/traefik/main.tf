resource "nomad_job" "traefik" {
  jobspec = <<EOF
job "traefik" {
  datacenters = ["${var.nomad_datacenter.name}"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port "http"{
         static = 80
      }
      port "admin"{
         static = 8080
      }
    }

    service {
      name = "traefik-http"
      provider = "nomad"
      port = "http"
    }

    task "server" {
      driver = "docker"
      config {
        image = "traefik:v2.10.1"
        ports = ["admin", "http"]
        args = [
          "--api.dashboard=true",
          "--api.insecure=true", ### For Test only, please do not use that in production
          "--entrypoints.web.address=:$${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:$${NOMAD_PORT_admin}",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=${var.nomad_region.address}"
        ]
      }
    }
  }
}
EOF
}
