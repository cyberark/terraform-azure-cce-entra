terraform {
  required_version = ">= 1.8.5"
}

module "cce" {
  source            = "./services_modules/cce"
  entra_id          = var.entra_id
  identity_issuer   = "https://placeholder-issuer.example.com"
  identity_user_id  = "placeholder-user-id"
  identity_audience = "placeholder-audience"
}
