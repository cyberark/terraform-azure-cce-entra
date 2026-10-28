# CCE Azure Microsoft Entra Tenant Onboarding Module

This Terraform module onboards Microsoft Entra tenants (formerly Azure AD) to Connect Cloud Environments (CCE) Idira SaaS services.
CCE helps customers easily adopt Idira services and establish secure trust relationships with their Azure environments.

## Overview  
This module creates the necessary Microsoft Entra ID applications, service principals, federated identity credentials, and role assignments required for secure cloud onboarding.

The module leverages Workload Identity Federation (WIF) to enable secure, passwordless authentication between Idira services and Azure resources.

## Features   
- **Automated CCE Application Setup**: Creates and configures Microsoft Entra ID app registration for CCE with required Microsoft Graph API permissions
- **Workload Identity Federation**: Implements federated identity credentials for secure, passwordless authentication
- **Role-Based Access Control**: Automatically assigns Management Group Reader role to CCE service principal
- **Microsoft Graph Permissions**: Configures required API permissions including CrossTenantInformation.ReadBasic.All

## Prerequisites

Before using this module, ensure that you have the following information and requirements:

1. **Idira Identity Security Platform Account**
   - API credentials (client ID and secret)
   - Tenant URL

2. **Azure Requirements**
   - Active Microsoft Entra tenant ID with appropriate permissions
   - Global Administrator or Application Administrator role
   - Permissions to create applications and grant admin consent
   - Azure CLI authenticated with appropriate permissions

3. **Terraform Requirements**
   - Terraform >= 1.8.5
   - Azure AD Provider ~> 3.0
   - Azure RM Provider ~> 4.0
   - Idira idsec Provider
4. **For SCA (Secure Cloud Access)**:
   - When SCA is enabled, use the Commons module (`terraform-azure-cce-commons`) in your root configuration and pass its `sca` output as `sca.shared_resources`.
5. **For Cloud Discovery**:
   - When Cloud Discovery is enabled, use the Commons module (`terraform-azure-cce-commons`) with `cds.enable = true` in your root configuration and pass its `cds` output as `cds.shared_resources`. See the `examples/cloud_discovery_onboarding` example in `terraform-azure-cce-commons`.

## Usage  

### Basic Example
```hcl
terraform {
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
  required_version = ">= 1.8.5"
}

provider "azurerm" {
  subscription_id = "your-subscription-id"
  features {}
}

provider "azuread" {}

module "cce_azure_entra" {
  source   = "path/to/module"
  entra_id = "your-entra-tenant-id"
  sia      = { enable = true }  # Optional: Enable SIA (Secure Infrastructure Access)
  sca = {
    enable           = true
    shared_resources = module.cce_azure_shared.sca  # From terraform-azure-cce-commons; required when SCA enabled
  }
  cds = {
    enable           = true
    shared_resources = module.cce_azure_shared.cds  # From terraform-azure-cce-commons; required when Cloud Discovery is enabled
  }
}
```

### Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `entra_id` | The Microsoft Entra tenant ID | `string` | n/a | yes |
| `sia` | Configuration for SIA (Secure Infrastructure Access) | `object({ enable = bool })` | `{ enable = false }` | no |
| `sca.enable` | Enable SCA (Secure Cloud Access) at Entra scope | `bool` | `false` | no |
| `sca.shared_resources` | SCA shared resources from Commons output (required when sca.enable = true). Must include entra_app_id, entra_custom_role_id, entra_wif_user_id, resource_app_id, resource_custom_role_id, resource_wif_user_id. | `object` | `null` | no |
| `sca.shared_resources.add_permissions_to_manage_cluster` | When true, assigns the K8s custom role at the root management group scope. Requires `resource_k8s_custom_role_id` to be non-empty. | `bool` | `false` | no |
| `sca.shared_resources.resource_k8s_custom_role_id` | The K8s custom role ID from Commons output (required when `add_permissions_to_manage_cluster` is true). | `string` | `null` | no |
| `cds.enable` | Enable Cloud Discovery at Entra scope | `bool` | `false` | no |
| `cds.shared_resources` | Cloud Discovery shared resources from Commons output (required when cds.enable = true). Must include entra_app_id, entra_wif_user_id, resource_app_id, resource_custom_role_id, resource_wif_user_id. | `object` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| `cce_app_id` | The CCE app (client) ID |
| `sia_app_id` | The SIA app (client) ID (if enabled) |
| `sca_app_id` | The SCA Entra application (client) ID (from commons, when SCA enabled) |
| `sca_resource_app_id` | The SCA Resource application (client) ID (from commons, when SCA enabled) |
| `entra_onboarding_id` | The ID of the Entra tenant onboarding in CCE (null when no service is enabled) |

### What Gets Created

#### CCE Module (Always Created)
- Microsoft Entra ID application: `CyberArk-CCE-app`
- Service principal with federated identity credentials
- Microsoft Graph API permission: `CrossTenantInformation.ReadBasic.All`
- Azure role assignment: `Management Group Reader`

#### SIA Module (Optional - when `sia.enable = true`)
- Microsoft Entra ID application: `CyberArk-dpa`
- Service principal with federated identity credentials
- Custom Azure role definition: `CyberArk-SIA-Role-{entra_id}-{uuid}`
- Role permissions for VM discovery and management:
  - Read VMs, network interfaces, public IPs
  - Read resource graph data

#### SCA (Optional - when `sca.enable = true` and `sca.shared_resources` set)
- Role assignment of the SCA Entra app (from commons) to the SCA Entra custom role at Entra/tenant scope
- SCA service registration in CCE for the Entra tenant. Resource app and role come from Commons; this module only performs the Entra-level assignment and idsec registration.
- When `shared_resources.add_permissions_to_manage_cluster` is true, assigns the K8s custom role (`resource_k8s_custom_role_id` from commons) at the root management group.

#### Cloud Discovery (Optional - when `cds.enable = true` and `cds.shared_resources` set)
- Role assignment of the Cloud Discovery resource app (from commons) to the Cloud Discovery resource custom role at the root management group
- Cloud Discovery service registration in CCE for the Entra tenant, carrying both Cloud Discovery apps (Entra and resource). The apps, custom roles and the Cloud Discovery Entra app's root management group assignment are created by Commons, since every onboarding level uses them.
- To offboard Cloud Discovery, set `cds.enable = false` and apply. Only after every level is offboarded, disable Cloud Discovery in Commons and apply to delete the shared resources. Do not remove the module block or run `terraform destroy`. This will offboard every service, not only Cloud Discovery.

## Documentation
For more detailed examples, see the [Basic Example](./examples/basic) directory.

For more information about Connect Cloud Environments, see [CyberArk Documentation](https://docs.cyberark.com/admin-space/latest/en/content/cce/cce-overview.htm).

## Licensing  
This repository is subject to the following licenses:  
- **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf).  
- **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE)).  

## Contributing  
We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## About  
CyberArk is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).  
