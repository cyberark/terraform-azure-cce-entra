variable "entra_id" {
  description = "The Azure Entra (management group) ID; scope for SCA Entra role assignment (same as commons role_definition_scope)."
  type        = string
}

variable "shared_resources" {
  description = "SCA shared resources from commons (created or passed through). Same shape always."
  type = object({
    entra_app_id            = optional(string)
    entra_custom_role_id    = optional(string)
    entra_wif_user_id       = optional(string)
    resource_app_id         = optional(string)
    resource_custom_role_id = optional(string)
    resource_wif_user_id    = optional(string)
  })
}
