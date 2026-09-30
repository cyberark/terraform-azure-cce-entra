output "cce_app_id" {
  value       = module.cce_azure_entra.cce_app_id
  description = "The CCE app (client) ID."
}

output "sia_app_id" {
  value       = module.cce_azure_entra.sia_app_id
  description = "The SIA app (client) ID."
}