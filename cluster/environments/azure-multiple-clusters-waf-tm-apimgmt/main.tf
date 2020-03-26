module "provider" {
  #source = "github.com/microsoft/bedrock?ref=master//cluster/azure/provider"
  source = "../../../cluster/azure/provider"
}

# Read AKS cluster service principal (client) object to create a role assignment
data "azuread_service_principal" "sp" {
  application_id = var.service_principal_id
}
