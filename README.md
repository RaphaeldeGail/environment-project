<!-- BEGIN_TF_DOCS -->
# environment-project

This terraform module sets up a Google Cloud project for an environment in a
workspace.

## Requirements

| Name | Version |
|------|---------|
| google | ~> 5.21.0 |
| google-beta | ~> 5.25.0 |
| random | ~> 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_project_service_identity.service_agent](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_project_service_identity) | resource |
| [google_billing_project_info.billing_association](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_project_info) | resource |
| [google_kms_crypto_key_iam_member.crypto_compute](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_project.environment_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |
| [google_project_iam_policy.instance_admins](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_policy) | resource |
| [google_project_service.service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_iam_policy.project_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| apis | A set of APIs to enable in the project. If the API has a service agent, a role can be specified. | ```set(object({ name = string role = optional(string) }))``` | n/a |
| billing\_account | The ID of the billing account used for the workspace. "Billing account User" permissions are required to execute module. | `string` | n/a |
| bindings | The IAM policy bindings for the project. | ```list(object({ role = string members = list(string) }))``` | n/a |
| folder | The ID of the Workspace Folder. | `number` | n/a |
| kms\_key | The ID of the symmetric crypto key for the workspace. | `string` | n/a |
| name | The name of the environment project. | `string` | n/a |

## Outputs

| Name | Description |
|------|-------------|
| compute\_zones | The names of the available compute zones for the project. |
| project\_id | The ID of the environment project created. |
<!-- END_TF_DOCS -->