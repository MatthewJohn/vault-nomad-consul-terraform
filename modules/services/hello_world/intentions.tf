resource "consul_config_entry" "service_intentions" {
  name = nomad_job.hellow-world.name
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = var.traefik.service_name
        Precedence = 9
        Type       = "consul"
      }
    ]
  })

  depends_on = [
    nomad_job.hellow-world
  ]
}