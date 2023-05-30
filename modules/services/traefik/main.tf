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
          #"--providers.nomad=true",
          #"--providers.nomad.endpoint.address=${var.nomad_region.address}"
          "--providers.consulcatalog.connectaware=true",
          # Make the communication secure by default
          "--providers.consulcatalog.connectbydefault=true",
          "--providers.consulcatalog.exposedbydefault=true",
          "--entrypoints.http=true",
          "--entrypoints.http.address=:8080",
          # The service name below should match the nomad/consul service above
          # and is used for intentions in consul
          "--providers.consulcatalog.servicename=traefik-ingress",
          "--providers.consulcatalog.prefix=traefik",

          # Automatically configured by Nomad through CONSUL_* environment variables
          # as long as client consul.share_ssl is enabled
          "--providers.consulcatalog.endpoint.address=<socket|address>"
          "--providers.consulcatalog.endpoint.tls.ca=<path>"
        #   "--providers.consulcatalog.endpoint.tls.cert=<path>"
        #   "--providers.consulcatalog.endpoint.tls.key=<path>"
          "--providers.consulcatalog.endpoint.token=<token>"
        ]
      }
    }
  }
}
EOF
}
