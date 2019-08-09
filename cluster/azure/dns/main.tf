module "azure-provider" {
  source = "../provider"
}

resource "azurerm_resource_group" "dnszone" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_dns_zone" "dnszone" {
  name = "${var.name}"
  resource_group_name = "${azurerm_resource_group.dnszone.name}"
  zone_type = "Public"
}

resource "azurerm_dns_caa_record" "dnszone_caa" {
  name = "caa"
  zone_name = "${azurerm_dns_zone.dnszone.name}"
  resource_group_name = "${azurerm_resource_group.dnszone.name}"
  ttl = 300

  record {
    flags = 0
    tag = "issue"
    value = "${var.caa_issuer}"
  }
}

resource "azurerm_role_assignment" "dnszone_contributor" {
  scope = "${azurerm_dns_zone.dnszone.id}"
  role_definition_name = "Contributor"
  principal_id = "${var.service_principal_id}"
}
