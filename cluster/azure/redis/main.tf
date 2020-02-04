provider "azurerm" {
  subscription_id = "${var.subscription_id}"
}

resource "azurerm_redis_cache" "redis" {
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  capacity            = "${var.capacity}"
  family              = "${var.family}"
  sku_name            = "${var.sku_name}"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {}
}

resource "null_resource" "set_redis_accesskey" {
  count = "${var.name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = "${path.module}/set_redis_accesskey.sh -n ${var.name} -g ${var.resource_group_name} -v ${var.vault_name} -a ${var.access_key_secret_name} -k ${azurerm_redis_cache.redis.primary_access_key} -s ${var.hostname_secret_name} -h ${azurerm_redis_cache.redis.hostname}"
  }

  triggers = {
    name                      = "${var.name}"
    vault_name                = "${var.vault_name}"
    access_key_secret_name    = "${var.access_key_secret_name}"
    access_key_secret_version = "${var.access_key_secret_version}"
    hostname_secret_name      = "${var.hostname_secret_name}"
    hostname_secret_version   = "${var.hostname_secret_version}"
  }

  depends_on = ["azurerm_redis_cache.redis"]
}
