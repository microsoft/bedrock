provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.login_service_principal_id}"
  client_secret   = "${var.login_service_principal_password}"
  tenant_id       = "${var.tenant_id}"
}

# Read AKS cluster service principal (client) object to create a role assignment
data "azuread_service_principal" "sp" {
  application_id = "${var.service_principal_id}"
}
