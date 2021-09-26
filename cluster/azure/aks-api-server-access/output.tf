output "api_server_open" {
  value = join("",null_resource.open_api_server.*.id)
}

output "api_server_closed" {
  value = join("",null_resource.close_api_server.*.id)
}