
# resource "azurerm_resource_group" "eastakscluster" {
#   name     = "${var.service_principal_is_owner == "1" ? local.east_rg_name : module.east_aks.cluster_derived_resource_group}"
#   location = "${local.east_rg_location}"
# }
# module "east_tm_endpoint" {
#   source = "../../azure/tm-endpoint-ip"

#   # resource_group_name                 = "${azurerm_resource_group.eastakscluster.name}"
#   resource_group_name                 = "${var.service_principal_is_owner == "1" ? local.east_rg_name : module.east_aks.cluster_derived_resource_group}"
#   resource_location                   = "${local.east_rg_location}"
#   traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
#   traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
#   endpoint_name                       = "${local.east_rg_location}-waf-ipeast"
#   public_ip_name                      = "${var.cluster_name}-waf-ipeast"
#   ip_address_out_filename             = "${local.east_ip_address_out_filename}"

#   tags = {
#     environment = "azure-multiple-clusters-waf-tm-apimgt east - ${var.cluster_name} - public ip"
#     # kubedone    = "${module.east_aks.kubeconfig_done}"
#   }
# }

# Create an application gateway east
resource "azurerm_application_gateway" "appgweast" {
  name                = "${var.prefix}appgweast"
  resource_group_name = "${azurerm_resource_group.eastrg.name}"
  location            = "eastus"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection" // "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       // "2.2.9"
    enabled          = true
  }

  gateway_ip_configuration {
    name      = "ip-configuration"
    subnet_id = "${module.east_vnet.vnet_subnet_ids[1]}" #  {module.central_vnet.vnet_subnet_ids[0]
    # subnet_id = "${module.central_vnet.vnet_subnet_ids[0]}"
  }

  frontend_port {
    name = "${var.prefix}-feport443"
    port = 443
  }

  frontend_port {
    name = "${var.prefix}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-feip"
    public_ip_address_id = "${module.east_tm_endpoint.public_ip_id}"
  }

  backend_address_pool {
    name            = "${var.prefix}-beappool1"
    # ip_address_list = ["10.0.1.4"]
  }

  backend_http_settings {
    name                  = "${var.prefix}-httpsetting1"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    # cookie_based_affinity = "Enabled"                    // "Disabled"
  }

  http_listener {
    name                           = "${var.prefix}-httplstn1"
    frontend_ip_configuration_name = "${var.prefix}-feip"
    frontend_port_name             = "${var.prefix}-feport"
    protocol                       = "Http"
  
  }


  request_routing_rule {
    name                       = "${var.prefix}-rule1"
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-httplstn1"
    backend_address_pool_name  = "${var.prefix}-beappool1"
    backend_http_settings_name = "${var.prefix}-httpsetting1"
  }

# depends_on = [
#      "azurerm_public_ip.wafipeast"

#   ]
}


# resource "azurerm_resource_group" "westtakscluster" {
#   name     = "${var.service_principal_is_owner == "1" ? local.west_rg_name : module.west_aks.cluster_derived_resource_group}"
#   location = "${local.west_rg_location}"
# }

# module "west_tm_endpoint" {
#   source = "../../azure/tm-endpoint-ip"

#   resource_group_name                 = "${var.service_principal_is_owner == "1" ? local.west_rg_name : module.west_aks.cluster_derived_resource_group}" #"${azurerm_resource_group.westtakscluster.name}"
#   resource_location                   = "${local.west_rg_location}"
#   traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
#   traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
#   endpoint_name                       = "${local.west_rg_location}-waf-ipwest"
#   public_ip_name                      = "${var.cluster_name}-waf-ipwest"
#   ip_address_out_filename             = "${local.west_ip_address_out_filename}"

#   tags = {
#     environment = "azure-multiple-clusters-waf-tm-apimgt west- ${var.cluster_name} - public ip"
#     # kubedone    = "${module.east_aks.kubeconfig_done}"
#   }
# }

# Create an application gateway east
resource "azurerm_application_gateway" "appgwwest" {
  name                = "${var.prefix}appgwwest"
  resource_group_name = "${azurerm_resource_group.westrg.name}"
  location            = "westus"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection" // "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       // "2.2.9"
    enabled          = true
  }

  gateway_ip_configuration {
    name      = "ip-configuration"
    subnet_id = "${module.west_vnet.vnet_subnet_ids[1]}"
  }

  frontend_port {
    name = "${var.prefix}-feport443"
    port = 443
  }

  frontend_port {
    name = "${var.prefix}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-feip"
    # public_ip_address_id = "${azurerm_public_ip.wafipwest.id}" module.east_tm_endpoint.pip.id
    public_ip_address_id = "${module.west_tm_endpoint.public_ip_id}"
  }

  backend_address_pool {
    name            = "${var.prefix}-beappool1"
    # ip_address_list = ["10.0.1.4"]
  }

  backend_http_settings {
    name                  = "${var.prefix}-httpsetting1"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "${var.prefix}-httplstn1"
    frontend_ip_configuration_name = "${var.prefix}-feip"
    frontend_port_name             = "${var.prefix}-feport"
    protocol                       = "Http"
  
  }


  request_routing_rule {
    name                       = "${var.prefix}-rule1"
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-httplstn1"
    backend_address_pool_name  = "${var.prefix}-beappool1"
    backend_http_settings_name = "${var.prefix}-httpsetting1"
  }

  
}


# resource "azurerm_resource_group" "centralakscluster" {
#   name     = "${var.service_principal_is_owner == "1" ? local.central_rg_name : module.central_aks.cluster_derived_resource_group}"
#   location = "${local.central_rg_location}"
# }

# module "central_tm_endpoint" {
#   source = "../../azure/tm-endpoint-ip"

#   resource_group_name                 = "${var.service_principal_is_owner == "1" ? local.central_rg_name : module.central_aks.cluster_derived_resource_group}"#"${azurerm_resource_group.centralakscluster.name}"
#   resource_location                   = "${local.central_rg_location}"
#   traffic_manager_resource_group_name = "${var.traffic_manager_resource_group_name}"
#   traffic_manager_profile_name        = "${var.traffic_manager_profile_name}"
#   endpoint_name                       = "${local.central_rg_location}-waf-ipcentral"
#   public_ip_name                      = "${var.cluster_name}-waf-ipcentral"
#   ip_address_out_filename             = "${local.central_ip_address_out_filename}"

#   tags = {
#     environment = "azure-multiple-clusters-waf-tm-apimgt - ${var.cluster_name} - public ip"
#     # kubedone    = "${module.east_aks.kubeconfig_done}"
#   }
# }

# Create an application gateway east
resource "azurerm_application_gateway" "appgwcentral" {
  name                = "${var.prefix}appgwcentral"
  resource_group_name = "${azurerm_resource_group.centralrg.name}"
  location            = "centralus"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection" // "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       // "2.2.9"
    enabled          = true
  }

  gateway_ip_configuration {
    name      = "ip-configuration"
    subnet_id = "${module.central_vnet.vnet_subnet_ids[1]}"
  }

  frontend_port {
    name = "${var.prefix}-feport443"
    port = 443
  }

  frontend_port {
    name = "${var.prefix}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-feip"
    public_ip_address_id = "${module.central_tm_endpoint.public_ip_id}"
  }

  backend_address_pool {
    name            = "${var.prefix}-beappool1"
    # ip_address_list = ["10.0.1.4"]
  }

  backend_http_settings {
    name                  = "${var.prefix}-httpsetting1"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    # cookie_based_affinity = "Enabled"                    // "Disabled"
  }

  http_listener {
    name                           = "${var.prefix}-httplstn1"
    frontend_ip_configuration_name = "${var.prefix}-feip"
    frontend_port_name             = "${var.prefix}-feport"
    protocol                       = "Http"
  
  }


  request_routing_rule {
    name                       = "${var.prefix}-rule1"
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-httplstn1"
    backend_address_pool_name  = "${var.prefix}-beappool1"
    backend_http_settings_name = "${var.prefix}-httpsetting1"
  }

}