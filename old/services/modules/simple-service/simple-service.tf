resource "null_resource" "deploy_simple_service" {
  provisioner "local-exec" {
    command = "${path.module}/deploy-simple-service ${var.environment} ${var.container_repo}"
  }
}
