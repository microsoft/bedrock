module "provider" {
  source = "github.com/Microsoft/bedrock/cluster/azure/provider"
}

# Read AKS cluster service principal (client) object to create a role assignment
data "azuread_service_principal" "sp" {
  application_id = "${var.service_principal_id}"
}
