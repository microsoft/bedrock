output "primary_access_key" {
  sensitive = true
  value     = "${azurerm_redis_cache.redis.primary_access_key}"
}

output "host_name" {
  value     = "${azurerm_redis_cache.redis.hostname}"
}
