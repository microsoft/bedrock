output "configmap_created" {
  value = "${join("",null_resource.create_k8s_configmap.*.id)}"
}