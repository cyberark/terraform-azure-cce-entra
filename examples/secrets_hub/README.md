# Example: Secrets Hub (CCE Commons + Entra)

Runs the Commons module to create the shared Secrets Hub identity, then passes its `secrets_hub` output to the Entra module. The Entra module onboards Secrets Hub at the root management group by assigning roles and registering it in CCE.

## What This Example Does

* Creates the shared Secrets Hub identity within the Commons module (application, service principal, federated identity credential, custom role)
* Passes the Commons `secrets_hub` output to the Entra module as `secrets_hub.shared_resources`, so the Entra module assigns the roles at the root management group and registers `secrets_hub` in the Entra onboarding
* Outputs the `secrets_hub` object and the Secrets Hub application ID

## Prerequisites

* Azure subscription and Microsoft Entra tenant
* Azure permissions: Application Administrator (app, service principal, federated credential), and Owner or User Access Administrator at the root management group (custom role and role assignments)
* Idira tenant with CCE and the idsec provider configured, with Secrets Hub activated on the tenant
* Terraform >= 1.8.5
* Idira `idsec` provider 0.12.1 configured — https://registry.terraform.io/providers/cyberark/idsec/latest/docs#example-usage

## Usage

1. From the `examples/secrets_hub` directory, copy `terraform.tfvars.example` to `terraform.tfvars` and update the values:

    ```hcl
    entra_id        = "00000000-0000-0000-0000-000000000000"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    ```

    * `entra_id`: your Microsoft Entra tenant ID.
    * `subscription_id`: an Azure subscription ID. The `azurerm` v4 provider requires it, even though this example onboards only the Entra tenant and creates no subscription-level resources.

2. Configure the idsec provider (for example, via environment variables or a provider block) with your Idira tenant credentials.

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

6. Verify the result:

    * Run `terraform output`. It shows `secrets_hub`, `secrets_hub_app_id`, and `entra_onboarding_id`.
    * Confirm that Secrets Hub appears in the onboarding for your Entra tenant in CCE.

## What Gets Created

In the names below, `<t>` is the last segment of your Idira tenant ID and `<e>` is the last segment of your Entra tenant ID.

### In Azure

Created by the Commons module:

* Microsoft Entra ID application and service principal `idira-secrets-hub-app-<t>-<e>`, tagged `secrets_hub-version:<version>`
* Federated identity credential `Idira-SecretsHub-Azure-Access`
* Custom Azure RBAC role `idira-secrets-hub-role-<t>-<e>` at the root management group

Created by the Entra module:

* Two role assignments at the root management group: the custom role and `Key Vault Secrets Officer`

### In CCE

* The Entra onboarding with a `secrets_hub` entry and one application

## Outputs

* `secrets_hub` — The Secrets Hub shared resources object (app_id, custom_role_id, identity_trusted_username). This example already passes it to the Entra module. Other consumers, such as the management group module, take it as `secrets_hub.shared_resources`.
* `secrets_hub_app_id` — The Secrets Hub application (client) ID.
* `entra_onboarding_id` — The ID of the Microsoft Entra tenant onboarding in CCE.

## Removing Secrets Hub

Set `secrets_hub = { enable = false }` in both the Commons and the Entra module and run one `terraform apply`, or run `terraform destroy` to remove all resources created by this example. See [Removing Secrets Hub](../../README.md#removing-secrets-hub).

## Notes

A tenant can be onboarded with Secrets Hub at one scope only. To onboard a management group instead of the Entra root, use the `examples/secrets_hub` example of the `terraform-azure-cce-management-group` module.
