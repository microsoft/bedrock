module "west_waf_subnet" {
  source = "github.com/microsoft/bedrock?ref=0.11.1//cluster/azure/subnet"

  resource_group_name = "${azurerm_resource_group.westrg.name}"
  vnet_name           = "${module.west_vnet.vnet_name}"
  subnet_name         = "${var.prefix}-westwaf"
  address_prefix      = "${var.west_waf_address_prefix}"
}

module "west_waf" {
  source = "github.com/microsoft/bedrock?ref=0.11.1//cluster/azure/waf"

  resource_group_name     = "${azurerm_resource_group.westrg.name}"
  resource_group_location = "${azurerm_resource_group.westrg.location}"
  wafname                 = "${var.prefix}-west-waf"
  subnet_id               = "${module.west_waf_subnet.subnet_id}"
  public_ip_address_id    = "${module.west_tm_endpoint.public_ip_id}"
}
