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
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}


locals {
  apis = setunion([for api in var.apis : api.name], ["iam.googleapis.com"])

  agent_apis = { for api in var.apis : api.name => api.role if api.role != null }
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
  project  = google_project.environment_project.project_id

  service = each.key

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

resource "google_project_service_identity" "service_agent" {
  provider = google-beta

  for_each = local.agent_apis
  project  = google_project.environment_project.project_id
  service  = each.key
}

data "google_iam_policy" "project_policy" {
  binding {
    role = "roles/editor"
    members = [
      "serviceAccount:${google_project.environment_project.number}@cloudservices.gserviceaccount.com",
    ]
  }
  dynamic "binding" {
    for_each = local.agent_apis
    content {
      role = binding.value
      members = [
        "serviceAccount:${google_project_service_identity.service_agent[binding.key]}"
      ]
    }
  }

  dynamic "binding" {
    for_each = var.bindings
    content {
      role    = binding.value.role
      members = binding.value.members
    }
  }
}

resource "google_project_iam_policy" "instance_admins" {
  project     = google_project.environment_project.project_id
  policy_data = data.google_iam_policy.project_policy.policy_data

  depends_on = [
    google_project_service.service["iam.googleapis.com"],
    google_project_service.service["compute.googleapis.com"]
  ]
}

resource "google_kms_crypto_key_iam_member" "crypto_compute" {
  crypto_key_id = var.kms_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${google_project.environment_project.number}@compute-system.iam.gserviceaccount.com"

  depends_on = [
    google_project_service.service["compute.googleapis.com"]
  ]
}

data "google_compute_zones" "available" {
  project = google_project.environment_project.project_id

  depends_on = [
    google_project_service.service["compute.googleapis.com"]
  ]
}