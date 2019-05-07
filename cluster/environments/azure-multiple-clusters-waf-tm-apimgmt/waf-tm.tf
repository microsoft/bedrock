

# Create an application gateway east
resource "azurerm_application_gateway" "appgweast" {
  name                = "${var.prefix}appgweast"
  resource_group_name = "${azurerm_resource_group.eastrg.name}"
  location            = "${azurerm_resource_group.eastrg.location}"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       // "2.2.9"
    enabled          = true
  }

  gateway_ip_configuration {
    name      = "ip-configuration"
    subnet_id = "${module.east_vnet.vnet_subnet_ids[1]}" 
   
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

}


# Create an application gateway east
resource "azurerm_application_gateway" "appgwwest" {
  name                = "${var.prefix}appgwwest"
  resource_group_name = "${azurerm_resource_group.westrg.name}"
  location            = "${azurerm_resource_group.westrg.location}"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection" 
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       
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
    public_ip_address_id = "${module.west_tm_endpoint.public_ip_id}"
  }

  backend_address_pool {
    name            = "${var.prefix}-beappool1"
    
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


# Create an application gateway east
resource "azurerm_application_gateway" "appgwcentral" {
  name                = "${var.prefix}appgwcentral"
  resource_group_name = "${azurerm_resource_group.centralrg.name}"
  location            = "${azurerm_resource_group.centralrg.location}"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection" 
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"      
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