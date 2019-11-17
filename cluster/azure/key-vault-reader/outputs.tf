output "kvreader_created" {
  value = "${join("",null_resource.keyvault_reader.*.id)}"
}