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

variable "exec_group" {
  type        = string
  description = "The email address of the Google group with usage permissions for the workstation."
  nullable    = false
}

variable "kms_key" {
  type        = string
  description = "The ID of the symmetric crypto key for the workspace."
}