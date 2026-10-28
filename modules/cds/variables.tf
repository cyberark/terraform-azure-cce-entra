variable "entra_id" {
  description = "The Microsoft Entra tenant (management group) ID; scope for CDS resource role assignment (same as commons role_definition_scope)."
  type        = string
}

variable "shared_resources" {
  description = "CDS shared resources from commons (resource_app_id and resource_custom_role_id used here). Validated at Entra root when cds.enable is true."
  type = object({
    resource_app_id         = string
    resource_custom_role_id = string
  })
}
