output "dnszone_created" {
  value = "${join("",null_resource.dnszone.*.id)}"
}