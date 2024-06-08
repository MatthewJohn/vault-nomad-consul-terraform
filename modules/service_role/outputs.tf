output "harbor_projects" {
  description = "List of harbor projects for service"
  value = [
    for project in harbor_project.this : project.name
  ]
}