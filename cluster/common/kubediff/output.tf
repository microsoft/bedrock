output "kubediff_done" {
  value = join("",null_resource.deploy_kubediff.*.id)
}
