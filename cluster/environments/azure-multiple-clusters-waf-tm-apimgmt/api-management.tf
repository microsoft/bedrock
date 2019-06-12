module "central_vnet" {
  source = "../../azure/api-mgmt"

  api_mgmt_name     = "apiterraarmdeploy"
  resource_group_name = "${azurerm_resource_group.tmrg.name}"
  traffic_manager_fqdn = "${module.trafficmanager.traffic_manager_fqdn}"
  service_apim_name = "${var.service_apim_name}"

  tags = {
    environment = "azure-multiple-clusters-waf-tm-apimgmt"
  }
}