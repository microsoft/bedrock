
output "public_ip" {
  # value = "${azurerm_public_ip.pip.ip_address}"
  value = "${azurerm_public_ip.pip.ip_address}"
}

output "public_ip_id" {
  value = "${azurerm_public_ip.pip.id}"
}
