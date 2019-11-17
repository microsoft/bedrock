output "pod_identity_created" {
  value = "${join("",null_resource.pod_identity.*.id)}"
}