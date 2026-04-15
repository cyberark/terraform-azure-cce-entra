terraform {
  required_version = ">= 1.8.5"
  required_providers {
    idsec = {
      source  = "cyberark/idsec"
      version = "~> 0.2.1"
    }
  }
}

data "idsec_cce_azure_identity_params" "get_wif_data" {}

locals {
  cce_wif_data               = data.idsec_cce_azure_identity_params.get_wif_data.identity_params["cloud_onboarding"]
  sia_wif_data               = try(data.idsec_cce_azure_identity_params.get_wif_data.identity_params["dpa"], null)
  at_least_1_service_enabled = var.sia.enable == true || var.sca.enable == true
}
module "cce" {
  source            = "./services_modules/cce"
  entra_id          = var.entra_id
  identity_issuer   = local.cce_wif_data["identity_app_issuer"]
  identity_user_id  = local.cce_wif_data["identity_user_id"]
  identity_audience = local.cce_wif_data["identity_app_audience"]
  count             = local.at_least_1_service_enabled ? 1 : 0
}


module "sia" {
  source            = "./services_modules/sia"
  entra_id          = var.entra_id
  identity_issuer   = local.sia_wif_data["identity_app_issuer"]
  identity_user_id  = local.sia_wif_data["identity_user_id"]
  identity_audience = local.sia_wif_data["identity_app_audience"]
  count             = var.sia.enable ? 1 : 0
}

module "sca" {
  source           = "./services_modules/sca"
  count            = var.sca.enable && var.sca.shared_resources != null ? 1 : 0
  entra_id         = var.entra_id
  shared_resources = var.sca.shared_resources
}

resource "idsec_cce_azure_entra" "create_entra" {
  entra_id = var.entra_id
  count    = local.at_least_1_service_enabled ? 1 : 0
  cce_resources = {
    appId = module.cce[0].cce_app_id
  }

  # Ensure CCE, SIA (if used), and SCA (if used) are ready before idsec adds the Entra tenant
  depends_on = [module.cce, module.sia, module.sca]

  services = concat(
    # Add sia service if enabled and idsec provides dpa WIF data
    var.sia.enable ? [
      {
        service_name = "dpa"
        resources = {
          application_ids = [module.sia[0].sia_app_id]
        }
      }
    ] : [],
    var.sca.enable && var.sca.shared_resources != null ? [
      {
        service_name = "sca"
        resources = {
          applications = [
            {
              application_id            = var.sca.shared_resources.entra_app_id
              identity_trusted_username = var.sca.shared_resources.entra_wif_user_id
            },
            {
              application_id            = var.sca.shared_resources.resource_app_id
              identity_trusted_username = var.sca.shared_resources.resource_wif_user_id
            }
          ]
        }
      }
    ] : []
  )
}