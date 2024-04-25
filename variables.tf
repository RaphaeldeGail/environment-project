variable "name" {
  type        = string
  description = "The name of the environment project."
  nullable    = false
}

variable "folder" {
  type        = number
  description = "The ID of the Workspace folder."
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
    service_agent = optional(object({
      email = string
      role  = string
    }))
  }))
  description = "A set of APIs to enable in the environment project. If the API has a service agent, a role and email can be specified."
  nullable    = true
}

variable "bindings" {
  type = list(object({
    role    = string
    members = list(string)
  }))
  description = "The IAM policy bindings for the environment project."
  nullable    = true
}