output "cce_app_id" {
  value       = module.cce_azure_entra.cce_app_id
  description = "The Application (client) ID of the CCE app"
}

output "sia_app_id" {
  value       = module.cce_azure_entra.sia_app_id
  description = "The Application (client) ID of the SIA app"
}