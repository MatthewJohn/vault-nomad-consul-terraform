resource "nomad_job" "hellow-world" {
  jobspec = <<EOHCL
  
job "hello-world" {
  datacenters = ["${var.nomad_datacenter.name}"]

  meta {
    // User-defined key/value pairs that can be used in your jobs.
    // You can also use this meta block within Group and Task levels.
    foo = "bar"
  }

  group "servers" {

    count = 1
    
    network {
      mode = "bridge"
    }

    service {
      name = "hello-world"
      port = 8001
      tags = ["traefik-routing"]

      connect {
        sidecar_service {}

        sidecar_task {
          resources {
            cpu    = 50
            memory = 48
          }
        }
      }
    }

    task "web" {
      driver = "docker"

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

      resources {
        cpu    = 50
        memory = 32
      }
    }
  }
}
EOHCL
}
