module "east_waf_subnet" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/subnet"

  resource_group_name = "${azurerm_resource_group.eastrg.name}"
  vnet_name           = "${module.east_vnet.vnet_name}"
  subnet_name         = "${var.prefix}-eastwaf"
  address_prefix      = "${var.east_waf_address_prefix}"
}

module "east_waf" {
  source = "github.com/microsoft/bedrock?ref=master//cluster/azure/waf"

  resource_group_name     = "${azurerm_resource_group.eastrg.name}"
  resource_group_location = "${azurerm_resource_group.eastrg.location}"
  wafname                 = "${var.prefix}-east-waf"
  subnet_id               = "${module.east_waf_subnet.subnet_id}"
  public_ip_address_id    = "${module.east_tm_endpoint.public_ip_id}"
}
