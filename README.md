# CyberArk Azure Entra ID Integration with Terraform

## Overview  
This Terraform module automates the deployment and configuration of CyberArk Connect Cloud Environments (CCE) integration with Azure Entra ID (formerly Azure Active Directory). It creates the necessary Azure AD applications, service principals, federated identity credentials, and role assignments required for secure cloud onboarding.

The module leverages Workload Identity Federation (WIF) to enable secure, passwordless authentication between CyberArk services and Azure resources.

## Features   
- **Automated CCE Application Setup**: Creates and configures Azure AD application for CyberArk CCE with required Microsoft Graph API permissions
- **Workload Identity Federation**: Implements federated identity credentials for secure, passwordless authentication
- **Role-Based Access Control**: Automatically assigns Management Group Reader role to CCE service principal
- **Optional Service Modules**: Support for additional services (dummy and dummy_two) that can be enabled/disabled as needed
- **Microsoft Graph Permissions**: Configures required API permissions including CrossTenantInformation.ReadBasic.All, AuditLog.Read.All, and Directory.Read.All

## Prerequisites  
- **Terraform**: Version >= 1.8.5
- **Azure Entra ID**: Active Azure Entra ID (Tenant) with appropriate permissions
- **Azure AD Permissions**: Global Administrator or Application Administrator role to create applications and grant admin consent
- **CyberArk Identity Security Platform**: Access to CyberArk IdSec provider credentials
- **Required Providers**:
  - `hashicorp/azuread` ~> 3.0
  - `hashicorp/azurerm` ~> 4.0
  - `cyberark/idsec` ~> 0.1

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
    idsec = {
      source  = "cyberark/idsec"
      version = "~> 0.1"
    }
  }
  required_version = ">= 1.8.5"
}

provider "azurerm" {
  subscription_id = "your-subscription-id"
  features {}
}

provider "azuread" {}

provider "idsec" {
  # Configure your CyberArk credentials here or via environment variables
}

module "cce_azure_entra" {
  source   = "path/to/module"
  entra_id = "your-entra-tenant-id"
}
```

### Full Services Example
```hcl
module "cce_azure_entra" {
  source   = "path/to/module"
  entra_id = "your-entra-tenant-id"
  
  # Enable optional services
  dummy = {
    enable = true
  }
  
  dummy_two = {
    enable = true
  }
}
```

### Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `entra_id` | The Azure Entra ID (Tenant ID) | `string` | n/a | yes |
| `dummy` | Configuration for the dummy service feature | `object({ enable = optional(bool, true) })` | `{ enable = false }` | no |
| `dummy_two` | Configuration for the dummy_two service feature | `object({ enable = optional(bool, true) })` | `{ enable = false }` | no |

### Outputs

| Name | Description |
|------|-------------|
| `cce_app_id` | The Application (client) ID of the CCE app |
| `dummy_app_id` | The Application (client) ID of the CyberArk Dummy app (if enabled) |
| `dummy_two_app_id` | The Application (client) ID of the CyberArk Dummy Two app (if enabled) |

### What Gets Created

#### CCE Module (Always Created)
- Azure AD Application: `CyberArk-CCE-app`
- Service Principal with federated identity credentials
- Microsoft Graph API permission: `CrossTenantInformation.ReadBasic.All`
- Azure role assignment: `Management Group Reader`

#### Dummy Module (Optional)
- Azure AD Application: `CyberArk-Dummy-app`
- Service Principal with federated identity credentials
- Microsoft Graph API permissions:
  - `AuditLog.Read.All`
  - `Directory.Read.All`

#### Dummy Two Module (Optional)
- Azure AD Application: `CyberArk-DummyTwo-app`
- Service Principal with federated identity credentials
- Azure role assignment: `cyberark-cob-dummy-two-test-role`

## Documentation
For more detailed examples, see the [examples](./examples) directory:
- [Basic Example](./examples/basic) - Minimal configuration with CCE and one service (dummy) only
- [Full Services Example](./examples/full_services) - Complete configuration with all optional services enabled

For more information about CyberArk Connect Cloud Environments, visit the [CyberArk Documentation](https://docs.cyberark.com).

## Licensing  
This repository is subject to the following licenses:  
- **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf).  
- **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE)).  

## Contributing  
We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## About  
CyberArk is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).  