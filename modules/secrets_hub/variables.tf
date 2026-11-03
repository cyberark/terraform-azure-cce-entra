variable "entra_id" {
  description = "The Microsoft Entra tenant ID. It is also the ID of the root management group, where the Secrets Hub role assignments are created."
  type        = string
}

variable "shared_resources" {
  description = "Secrets Hub shared resources from commons (the commons secrets_hub output)."
  type = object({
    app_id                    = optional(string)
    custom_role_id            = optional(string)
    identity_trusted_username = optional(string)
  })
}
