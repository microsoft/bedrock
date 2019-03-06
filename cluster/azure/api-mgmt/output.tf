output "scm_url" {
  description = "The url of the API management source code management url"
  value       = "${azurerm_api_management.apimgmt.scm_url}"
}

output "management_api_url" {
  description = "The URL for the Management API associated with this API Management service."
  value = "${azurerm_api_management.apimgmt.management_api_url}"
}