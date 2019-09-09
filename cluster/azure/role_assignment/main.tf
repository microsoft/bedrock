resource "azurerm_role_assignment" "role" {
  scope                = "${var.role_scope}"
  role_definition_name = "${var.role_assignment_role}"
  principal_id         = "${var.role_assignee}"
}