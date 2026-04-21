variable "entra_id" {
  description = "The Azure Entra (management group) ID"
  type        = string
}

variable "identity_issuer" {
  description = "The identity issuer for the federated identity credential"
  type        = string
}

variable "identity_user_id" {
  description = "The identity user ID for the federated identity credential"
  type        = string
}

variable "identity_audience" {
  description = "The identity audience for the federated identity credential"
  type        = string
}
