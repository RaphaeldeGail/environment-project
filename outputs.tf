output "compute_zones" {
  value       = data.google_compute_zones.available.names
  description = "The names of the available compute zones for the environment project."
}

output "project_id" {
  value       = google_project.environment_project.project_id
  description = "The ID of the environment project created."
}

output "apis" {
  value = [for api in var.apis : {
    name          = api.name
    service_agent = api.service_agent != null ? { email = replace(api.service_agent.email, "PROJECT-NUMBER", google_project.environment_project.number), role = api.service_agent.role } : null
  }]
  description = "The effective APIs enabled for the environment project."
}