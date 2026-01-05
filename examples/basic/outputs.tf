output "cce_app_id" {
  value       = module.cce_azure_entra.cce_app_id
  description = "The Application (client) ID of the CCE app"
}

output "dummy_app_id" {
  value       = module.cce_azure_entra.dummy_app_id
  description = "The Application (client) ID of the CyberArk Dummy app"
}