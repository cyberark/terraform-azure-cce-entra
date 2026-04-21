terraform {
  required_version = ">= 1.8.5"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Look up the SCA Entra app's service principal (from commons)
data "azuread_service_principal" "entra_app_sp" {
  client_id = var.shared_resources.entra_app_id
}

# Assign the SCA Entra app to the SCA Entra custom role at Entra scope (consistent with MG/Sub doing assignment in their repo)
resource "azurerm_role_assignment" "sca_entra_role_assignment" {
  scope              = "/providers/Microsoft.Management/managementGroups/${var.entra_id}"
  role_definition_id = var.shared_resources.entra_custom_role_id
  principal_id       = data.azuread_service_principal.entra_app_sp.object_id
}