resource "nomad_job" "hello-world" {
  jobspec = <<EOHCL
  
job "${var.service_role.name}" {
  datacenters = ["${var.service_role.nomad.datacenter}"]

  meta {
    // User-defined key/value pairs that can be used in your jobs.
    // You can also use this meta block within Group and Task levels.
    foo = "bar"
  }

  group "servers" {

    count = 1
    
    network {
      mode = "bridge"

      port "http" {
        to = 8001
      }
      port "metrics_envoy" {
        to = 9102
      }
    }

    service {
      name = "${var.service_role.consul_service_name}"
      port = 8001
      tags = ["traefik-routing"]

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

    ephemeral_disk {
      size = 105
    }

    task "web" {
      driver = "docker"

      config {
        image   = "busybox:1"
        command = "httpd"
        args    = ["-v", "-f", "-p", "8001", "-h", "/local"]
        ports   = ["http"]
      }

      vault {
        policies = ["${var.service_role.vault_application_policy}"]
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

      resources {
        cpu    = 50
        memory = 32
      }
    }
  }
}
EOHCL

  consul_token = data.vault_generic_secret.consul_token.data["token"]
  vault_token  = vault_token.role_token.client_token
}
