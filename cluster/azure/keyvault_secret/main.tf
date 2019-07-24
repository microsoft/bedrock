resource "azurerm_key_vault_secret" "keyvault" {
  count = "${var.secret_name == "" ? 0 : 1}"

  name         = "${var.secret_name}"
  value        = "${var.secret_value}"
  key_vault_id = "${var.vault_id}"
}
