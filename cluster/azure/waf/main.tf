data "azurerm_resource_group" "wafrg" {
  name     = var.resource_group_name
}

resource "azurerm_application_gateway" "waf" {
  name                = var.wafname-waf
  resource_group_name = data.azurerm_resource_group.wafrg.name
  location            = data.azurerm_resource_group.wafrg.location

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
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = var.prefix-feport443
    port = 443
  }

  frontend_port {
    name = var.prefix-feport
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.prefix-feip
    public_ip_address_id = var.public_ip_address_id
  }

  backend_address_pool {
    name = var.prefix}-beappool1
  }

  backend_http_settings {
    name                  = var.prefix-httpsetting1
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = var.prefix-httplstn1
    frontend_ip_configuration_name = var.prefix-feip
    frontend_port_name             = var.prefix-feport
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.prefix-rule1
    rule_type                  = "Basic"
    http_listener_name         = var.prefix-httplstn1
    backend_address_pool_name  = var.prefix-beappool1
    backend_http_settings_name = var.prefix-httpsetting1
  }
}
