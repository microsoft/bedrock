module "east_waf_subnet" {
  source = "../../../cluster/azure/subnet"

  resource_group_name = data.azurerm_resource_group.eastrg.name
  vnet_name           = module.east_vnet.vnet_name
  subnet_name         = [ "${var.prefix}-eastwaf" ]
  address_prefix      = [ var.east_waf_address_prefix ]
}

module "east_waf" {
  source = "../../../cluster/azure/waf"

  resource_group_name     = data.azurerm_resource_group.eastrg.name
  wafname                 = "${var.prefix}-east-waf"
  subnet_id               = tostring(element(module.east_waf_subnet.subnet_ids, 0))
  public_ip_address_id    = module.east_tm_endpoint.public_ip_id
}
