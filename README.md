# CyberArk Azure Entra ID Integration with Terraform

## Overview  
This Terraform module automates the deployment and configuration of CyberArk Connect Cloud Environments (CCE) integration with Azure Entra ID (formerly Azure Active Directory). It creates the necessary Azure AD applications, service principals, federated identity credentials, and role assignments required for secure cloud onboarding.

The module leverages Workload Identity Federation (WIF) to enable secure, passwordless authentication between CyberArk services and Azure resources.

## Features   
- **Automated CCE Application Setup**: Creates and configures Azure AD application for CyberArk CCE with required Microsoft Graph API permissions
- **Workload Identity Federation**: Implements federated identity credentials for secure, passwordless authentication
- **Role-Based Access Control**: Automatically assigns Management Group Reader role to CCE service principal
- **Microsoft Graph Permissions**: Configures required API permissions including CrossTenantInformation.ReadBasic.All

## Prerequisites  
- **Terraform**: Version >= 1.8.5
- **Azure Entra ID**: Active Azure Entra ID (Tenant) with appropriate permissions
- **Azure AD Permissions**: Global Administrator or Application Administrator role to create applications and grant admin consent
- **Required Providers**:
  - `hashicorp/azuread` ~> 3.0
  - `hashicorp/azurerm` ~> 4.0

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
}
```

### Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `entra_id` | The Azure Entra ID (Tenant ID) | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| `cce_app_id` | The Application (client) ID of the CCE app |

### What Gets Created

#### CCE Module
- Azure AD Application: `CyberArk-CCE-app`
- Service Principal with federated identity credentials
- Microsoft Graph API permission: `CrossTenantInformation.ReadBasic.All`
- Azure role assignment: `Management Group Reader`

## Documentation
For more detailed examples, see the [Basic Example](./examples/basic) directory.

For more information about CyberArk Connect Cloud Environments, visit the [CyberArk Documentation](https://docs.cyberark.com).

## Licensing  
This repository is subject to the following licenses:  
- **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf).  
- **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE)).  

## Contributing  
We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## About  
CyberArk is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).  