module "west_waf_subnet" {
  source = "../../../cluster/azure/subnet"

  resource_group_name = data.azurerm_resource_group.westrg.name
  vnet_name           = module.west_vnet.vnet_name
  subnet_name         = [ "${var.prefix}-westwaf" ]
  address_prefix      = [ var.west_waf_address_prefix ]
}

module "west_waf" {
  source = "../../azure/waf"

  resource_group_name     = data.azurerm_resource_group.westrg.name
  wafname                 = "${var.prefix}-west-waf"
  subnet_id               = tostring(element(module.west_waf_subnet.subnet_ids, 0))
  public_ip_address_id    = module.west_tm_endpoint.public_ip_id
}
