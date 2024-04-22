variable "name" {
  type        = string
  description = "The name of the environment project."
  nullable    = false
}

variable "folder" {
  type        = number
  description = "The ID of the Workspace Folder."
  nullable    = false
}

variable "billing_account" {
  type        = string
  description = "The ID of the billing account used for the workspace. \"Billing account User\" permissions are required to execute module."
  nullable    = false
}

variable "apis" {
  type = set(object({
    name = string
    role = optional(string)
  }))
  description = "A set of APIs to enable in the project. If the API has a service agent, a role can be specified."
  nullable    = true
}

variable "bindings" {
  type = list(object({
    role    = string
    members = list(string)
  }))
  description = "The IAM policy bindings for the project."
  nullable    = true
}

variable "kms_key" {
  type        = string
  description = "The ID of the symmetric crypto key for the workspace."
  nullable    = true
}