/**
 * # environment-project
 * 
 * This terraform module sets up a Google Cloud project for an environment in a
 * workspace.
 *
 */

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.21.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

locals {
  apis     = setunion([for api in var.apis : api.name], ["iam.googleapis.com"])
  bindings = setunion(var.bindings, [for api in var.apis : { role = api.service_agent.role, members = [replace("serviceAccount:${api.service_agent.email}", "PROJECT_NUMBER", google_project.environment_project.number)] } if api.service_agent != null])
}

data "google_project" "admin_project" {
  # will use the project from the provider configuration.
}

resource "random_string" "random" {
  length      = 4
  keepers     = null
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  upper       = false
  special     = false
}

resource "google_project" "environment_project" {
  name       = title(replace(var.name, "-", " "))
  project_id = join("-", [var.name, random_string.random.result])
  folder_id  = var.folder

  skip_delete = false

  lifecycle {
    ignore_changes = [billing_account]
  }
}

resource "google_billing_project_info" "billing_association" {
  project         = google_project.environment_project.project_id
  billing_account = var.billing_account
}

resource "google_project_service" "service" {
  for_each = local.apis

  project = google_project.environment_project.project_id
  service = each.value

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
  disable_on_destroy         = true

  depends_on = [
    google_billing_project_info.billing_association
  ]
}

data "google_iam_policy" "project_policy" {
  binding {
    role = "roles/editor"
    members = [
      "serviceAccount:${google_project.environment_project.number}@cloudservices.gserviceaccount.com",
      "serviceAccount:administrator@${data.google_project.admin_project.project_id}.iam.gserviceaccount.com"
    ]
  }

  dynamic "binding" {
    for_each = local.bindings
    content {
      role    = binding.value.role
      members = binding.value.members
    }
  }
}

resource "google_project_iam_policy" "project_policy" {
  project     = google_project.environment_project.project_id
  policy_data = data.google_iam_policy.project_policy.policy_data

  depends_on = [
    google_project_service.service
  ]
}