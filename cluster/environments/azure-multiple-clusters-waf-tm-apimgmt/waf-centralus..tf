module "central_waf_subnet" {
  source = "github.com/microsoft/bedrock?ref=0.11.1//cluster/azure/subnet"

  resource_group_name = "${azurerm_resource_group.centralrg.name}"
  vnet_name           = "${module.central_vnet.vnet_name}"
  subnet_name         = "${var.prefix}-centralwaf"
  address_prefix      = "${var.central_waf_address_prefix}"
}

module "central_waf" {
  source = "github.com/microsoft/bedrock?ref=0.11.1//cluster/azure/waf"

  resource_group_name     = "${azurerm_resource_group.centralrg.name}"
  resource_group_location = "${azurerm_resource_group.centralrg.location}"
  wafname                 = "${var.prefix}-central-waf"
  subnet_id               = "${module.central_waf_subnet.subnet_id}"
  public_ip_address_id    = "${module.central_tm_endpoint.public_ip_id}"
}
