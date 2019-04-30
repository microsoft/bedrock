output "flux_done" {
  value = "${join("",null_resource.deploy_flux.*.id)}"
}
