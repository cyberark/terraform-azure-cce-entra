output "secrets_hub" {
  value       = module.cce_azure_shared.secrets_hub
  description = "Secrets Hub shared resources from the Commons module (app_id, custom_role_id, identity_trusted_username). Consumed by the Entra or management group module as secrets_hub.shared_resources."
}

output "secrets_hub_app_id" {
  value       = module.cce_azure_shared.secrets_hub.app_id
  description = "The Secrets Hub application (client) ID."
}

output "entra_onboarding_id" {
  value       = module.cce_entra.entra_onboarding_id
  description = "The ID of the Microsoft Entra tenant onboarding in CCE."
}
