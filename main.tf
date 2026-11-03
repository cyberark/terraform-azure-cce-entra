terraform {
  required_version = ">= 1.8.5"
  required_providers {
    idsec = {
      source  = "cyberark/idsec"
      version = "0.12.1"
    }
  }
}

data "idsec_cce_azure_identity_params" "get_wif_data" {}

locals {
  cce_wif_data               = data.idsec_cce_azure_identity_params.get_wif_data.identity_params["cloud_onboarding"]
  sia_wif_data               = try(data.idsec_cce_azure_identity_params.get_wif_data.identity_params["dpa"], null)
  at_least_1_service_enabled = var.sia.enable == true || var.sca.enable == true || var.secrets_hub.enable == true || var.cds.enable == true
}
module "cce" {
  source            = "./modules/cce"
  entra_id          = var.entra_id
  identity_issuer   = local.cce_wif_data["identity_app_issuer"]
  identity_user_id  = local.cce_wif_data["identity_user_id"]
  identity_audience = local.cce_wif_data["identity_app_audience"]
  count             = local.at_least_1_service_enabled ? 1 : 0
}


module "sia" {
  source            = "./modules/sia"
  entra_id          = var.entra_id
  identity_issuer   = local.sia_wif_data["identity_app_issuer"]
  identity_user_id  = local.sia_wif_data["identity_user_id"]
  identity_audience = local.sia_wif_data["identity_app_audience"]
  count             = var.sia.enable ? 1 : 0
}

module "sca" {
  source           = "./modules/sca"
  count            = var.sca.enable && var.sca.shared_resources != null ? 1 : 0
  entra_id         = var.entra_id
  shared_resources = var.sca.shared_resources
}

module "secrets_hub" {
  source           = "./modules/secrets_hub"
  count            = var.secrets_hub.enable ? 1 : 0
  entra_id         = var.entra_id
  shared_resources = var.secrets_hub.shared_resources
}

module "cds" {
  source   = "./modules/cds"
  count    = var.cds.enable && var.cds.shared_resources != null ? 1 : 0
  entra_id = var.entra_id
  shared_resources = {
    resource_app_id         = var.cds.shared_resources.resource_app_id
    resource_custom_role_id = var.cds.shared_resources.resource_custom_role_id
  }
}

resource "idsec_cce_azure_entra" "create_entra" {
  entra_id    = var.entra_id
  cce_version = "0.0.1"
  count       = local.at_least_1_service_enabled ? 1 : 0
  cce_resources = {
    appId = module.cce[0].cce_app_id
  }

  # Ensure CCE, SIA (if used), SCA (if used), Secrets Hub (if used), and CDS (if used) are ready before idsec adds the Microsoft Entra tenant
  depends_on = [module.cce, module.sia, module.sca, module.secrets_hub, module.cds]

  # flatten, not concat: the services' resources have different types
  services = flatten([
    # Add SIA if enabled and idsec provides dpa WIF data
    var.sia.enable ? [
      {
        service_name = "dpa"
        version      = "0.0.1"
        resources = {
          application_ids = [module.sia[0].sia_app_id]
        }
      }
    ] : [],
    var.sca.enable && var.sca.shared_resources != null ? [
      {
        service_name = "sca"
        version      = "0.0.4"
        resources = merge(
          {
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
          },
          try(var.sca.shared_resources.add_permissions_to_manage_cluster, false) ? {
            add_permissions_to_manage_cluster = true
          } : {}
        )
      }
    ] : [],
    var.secrets_hub.enable ? [
      {
        service_name = "secrets_hub"
        version      = "0.0.3"
        resources = {
          applications = [
            {
              application_id            = var.secrets_hub.shared_resources.app_id
              identity_trusted_username = var.secrets_hub.shared_resources.identity_trusted_username
            }
          ]
        }
      }
    ] : [],
    var.cds.enable && var.cds.shared_resources != null ? [
      {
        service_name = "cds"
        version      = "2.1.0"
        resources = {
          application_ids = [
            var.cds.shared_resources.entra_app_id,
            var.cds.shared_resources.resource_app_id,
          ]
          applications = [
            {
              application_id            = var.cds.shared_resources.entra_app_id
              identity_trusted_username = var.cds.shared_resources.entra_wif_user_id
            },
            {
              application_id            = var.cds.shared_resources.resource_app_id
              identity_trusted_username = var.cds.shared_resources.resource_wif_user_id
            }
          ]
        }
      }
    ] : []
  ])
}