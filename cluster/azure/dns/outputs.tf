output "dnszone_created" {
  value = "${join("",null_resource.cname_traffic_manager.*.id)}"
}