variable "entra_id" {
  description = "The Azure entra ID"
  type        = string
}

variable "sia" {
  description = "Configuration for the sia feature."
  type = object({
    enable = optional(bool, true)
  })
  default = { enable = false }
}

variable "sca" {
  description = "SCA config. When enable is true, shared_resources (from commons output) is required; Entra only consumes it and does not create SCA resources."
  type = object({
    enable = optional(bool, true)
    shared_resources = optional(object({
      entra_app_id            = optional(string)
      entra_custom_role_id    = optional(string)
      entra_wif_user_id       = optional(string)
      resource_app_id         = optional(string)
      resource_custom_role_id = optional(string)
      resource_wif_user_id    = optional(string)
    }), null)
  })
  default = { enable = false, shared_resources = null }

  validation {
    condition = (
      !var.sca.enable ||
      (var.sca.shared_resources != null &&
        try(var.sca.shared_resources.entra_app_id, null) != null &&
        try(var.sca.shared_resources.entra_custom_role_id, null) != null &&
        try(var.sca.shared_resources.entra_wif_user_id, null) != null &&
        try(var.sca.shared_resources.resource_app_id, null) != null &&
        try(var.sca.shared_resources.resource_custom_role_id, null) != null &&
      try(var.sca.shared_resources.resource_wif_user_id, null) != null)
    )
    error_message = "When SCA is enabled (sca.enable = true), sca.shared_resources must be set and must include all fields: entra_app_id, entra_custom_role_id, entra_wif_user_id, resource_app_id, resource_custom_role_id, resource_wif_user_id (from commons output)."
  }
}

