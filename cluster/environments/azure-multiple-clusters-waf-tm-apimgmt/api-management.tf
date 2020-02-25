module "api-mgmt" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/api-mgmt"

  api_mgmt_name        = "apiterraarmdeploy"
  resource_group_name  = data.azurerm_resource_group.tmrg.name
  traffic_manager_fqdn = module.trafficmanager.traffic_manager_fqdn
  service_apim_name    = var.service_apim_name
}
