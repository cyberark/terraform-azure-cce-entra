output "cce_app_id" {
  value       = local.at_least_1_service_enabled ? module.cce[0].cce_app_id : null
  description = "The CCE app (client) ID."
}

output "sia_app_id" {
  value       = var.sia.enable ? module.sia[0].sia_app_id : null
  description = "The SIA app (client) ID."
}

# SCA outputs come from commons (shared_resources); same format whether commons created or passed through
output "sca_app_id" {
  value       = var.sca.enable && var.sca.shared_resources != null ? var.sca.shared_resources.entra_app_id : null
  description = "The SCA Microsoft Entra tenant app (client) ID (from commons)."
}

output "sca_resource_app_id" {
  value       = var.sca.enable && var.sca.shared_resources != null ? var.sca.shared_resources.resource_app_id : null
  description = "The SCA resource app (client) ID (from commons)."
}

output "entra_onboarding_id" {
  value       = length(idsec_cce_azure_entra.create_entra) > 0 ? idsec_cce_azure_entra.create_entra[0].id : null
  description = "The Microsoft Entra tenant onboarding resource ID. Returns null when no service is enabled."
}
