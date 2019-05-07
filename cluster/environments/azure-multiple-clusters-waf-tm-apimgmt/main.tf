module "provider" {
  source = "../../azure/provider"
}

# Read AKS cluster service principal (client) object to create a role assignment
data "azuread_service_principal" "sp" {
  //application_id = "${var.service_principal_id}"
  application_id = "f8ec33d6-dd15-45ef-a8f0-fb9d25c8f835"
}
