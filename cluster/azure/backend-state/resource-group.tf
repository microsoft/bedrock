resource "azurerm_resource_group" "remote_state_rg" {
  name     = "${var.resource_group_name == "" ? "${local.name}-remote-state-rg" : "${var.resource_group_name}"}"
  location = "${var.location}"
  tags     = "${merge(map("Name", "${local.name}"), var.resource_tags)}"
}
