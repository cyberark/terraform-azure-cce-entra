# Example: Basic CCE Microsoft Entra tenant Onboarding with SIA and SCA

This example demonstrates a basic configuration to onboard an Azure Entra tenant to CCE with SIA (Secure Infrastructure Access) enabled. SCA (Secure Cloud Access) can be enabled by passing `shared_resources` from the Commons module.

## What This Example Does

* Onboards your Microsoft Entra tenant ID to CCE  
* Creates the core CCE application with required permissions
* Enables SIA (Secure Infrastructure Access) for VM discovery and privileged access  
* Enables SCA at Entra scope (when `sca.shared_resources` from Commons is provided)

## Prerequisites

* Microsoft Entra tenant ID (formerly Azure AD)  
* Terraform >= 1.8.5  
* For SCA: run the Commons module first and pass its `sca` output as `shared_resources`

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values:  

    ```hcl
    entra_id = "0b659685-1a00-43cd-b994-555bac390ecf"
    ```

2. To enable SCA, call the Commons module in your root configuration and pass its output into this module:

    ```hcl
    module "cce_azure_shared" {
      source   = "path/to/terraform-azure-cce-commons"
      entra_id = var.entra_id
      sca      = { enable = true, parameters = { sca_entra_onboarding = true, ... } }
    }

    module "cce_azure_entra" {
      source   = "path/to/terraform-azure-cce-entra"
      entra_id = var.entra_id
      sia      = { enable = true }
      sca = {
        enable           = true
        shared_resources = module.cce_azure_shared.sca
      }
    }
    ```

3. Initialize Terraform:  

    ```bash
    terraform init
    ```

4. Review the plan:  

    ```bash
    terraform plan
    ```

5. Apply the configuration:  

    ```bash
    terraform apply
    ```

## What Gets Created

### In Azure 

**CCE Application:**
* Microsoft Entra ID application: `CyberArk-CCE-app`  
* Service principal for the CCE application  
* Microsoft Graph API Permissions with admin consent for CCE app:  
  * `CrossTenantInformation.ReadBasic.All` - Allows reading basic cross-tenant information  
* Azure role assignment: `Management Group Reader` at the Entra ID scope  
* Federated Identity Credential for workload identity federation

**SIA (Secure Infrastructure Access) Application:**
* Microsoft Entra ID application: `CyberArk-dpa`
* Service principal for SIA
* Custom role definition: `CyberArk-SIA-Role-{entra_id}-{uuid}` with permissions:
  - `Microsoft.Compute/virtualMachines/read`
  - `Microsoft.Network/networkInterfaces/read`
  - `Microsoft.Network/publicIPAddresses/read`
  - `Microsoft.ResourceGraph/resources/read`
* Federated Identity Credential for workload identity federation  

**When SCA is enabled** (with `sca.enable = true` and `sca.shared_resources` from Commons):
* Role assignment of the SCA Entra app (from Commons) to the SCA Entra custom role at Entra/tenant scope
* SCA service registration in CCE for the Entra tenant

### In CCE

* Microsoft Entra ID registration in CCE   
* When SCA is enabled: SCA service resources for the Entra tenant

## Outputs

This example outputs:

* `cce_app_id`: The Application (client) ID of the CCE app
* `sia_app_id`: The Application (client) ID of the SIA app (when SIA enabled)
* `sca_app_id`: The SCA Entra application (client) ID (when SCA enabled with shared_resources)
* `sca_resource_app_id`: The SCA Resource application (client) ID (when SCA enabled with shared_resources)  

## Next Steps

After successful deployment, verify the Microsoft Entra tenant appears in your CCE console.  
