# Example 1: Basic CCE Entra Onboarding

This example demonstrates a basic configuration to onboard an Azure Entra ID to CyberArk CCE (Connect Cloud Environments) with one optional service enabled.

## What This Example Does

* Onboards your Azure Entra ID to CyberArk CCE  
* Creates the core CCE application with required permissions  
* Enables Dummy - an example optional service  

## Prerequisites

* Azure Entra ID (formerly Azure AD)  
* CyberArk tenant with CCE  
* Terraform >= 1.8.5  
* CyberArk `idsec` provider configured - https://registry.terraform.io/providers/cyberark/idsec/latest/docs#example-usage  

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values:  

    ```hcl
    entra_id = "0b659685-1a00-43cd-b994-555bac390ecf"
    ```

2. Initialize Terraform:  

    ```bash
    terraform init
    ```

3. Review the plan:  

    ```bash
    terraform plan
    ```

4. Apply the configuration:  

    ```bash
    terraform apply
    ```

## What Gets Created

### In Azure 

**CCE Application:**
* Azure AD Application: `CyberArk-CCE-app`  
* Service Principal for the CCE application  
* Microsoft Graph API Permissions with admin consent for CCE app:  
  * `CrossTenantInformation.ReadBasic.All` - Allows reading basic cross-tenant information  
* Azure Role Assignment: `Management Group Reader` at the Entra ID scope  
* Federated Identity Credential for workload identity federation  

**Dummy Application (optional service):**
* Azure AD Application: `CyberArk-Dummy-app`  
* Service Principal for the Dummy application  
* Microsoft Graph API Permissions with admin consent:  
  * `AuditLog.Read.All` - Allows reading audit log data  
  * `Directory.Read.All` - Allows reading directory data  
* Federated Identity Credential for workload identity federation  

### In CyberArk

* Entra ID registration in CCE  
* Dummy service enabled  

## Outputs

This example outputs:

* `cce_app_id`: The Application (client) ID of the CCE app  
* `dummy_app_id`: The Application (client) ID of the CyberArk Dummy app  

## Next Steps

After successful deployment:

1. Verify the Entra ID appears in your CyberArk CCE console  
2. Verify Dummy service is active  
3. To enable additional services (dummy_two), see [full\_services](../full_services/)  
