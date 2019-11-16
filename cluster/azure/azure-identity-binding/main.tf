resource "null_resource" "azure_identity" {
  count = "${var.aks_resource_group_name != "" && var.kv_reader_identity_name != "" && var.azure_identity_name != "" && var.k8s_namespace != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = <<-EOT
      echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done}; \
      KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} \
      pwsh ${path.module}/create_azure_identity.ps1 \
      -KVReaderIdentityName ${var.kv_reader_identity_name} \
      -AksResourceGroupName ${var.aks_resource_group_name} \
      -AzureIdentityName ${var.azure_identity_name} \
      -AzureBindingKubeNamespace ${var.k8s_namespace}
    EOT
  }

  triggers = {
    aks_resource_group_name = "${var.aks_resource_group_name}"
    kv_reader_identity_name = "${var.kv_reader_identity_name}"
    azure_identity_name     = "${var.azure_identity_name}"
    k8s_namespace           = "${var.k8s_namespace}"
  }
}

resource "null_resource" "azure_identity_binding" {
  count = "${var.aks_resource_group_name != "" && var.kv_reader_identity_name != "" && var.azure_identity_name != "" && var.k8s_namespace != "" && var.azure_identity_binding_name != "" ? 1 : 0}"

  provisioner "local-exec" {
    command = <<-EOT
      echo 'Need to use this var so terraform waits for kubeconfig ' ${var.kubeconfigadmin_done}; \
      KUBECONFIG=${var.output_directory}/${var.kubeconfigadmin_filename} \
      pwsh ${path.module}/create_azure_identity_binding.ps1 \
      -KVReaderIdentityName ${var.kv_reader_identity_name} \
      -AksResourceGroupName ${var.aks_resource_group_name} \
      -AzureIdentityName ${var.azure_identity_name} \
      -AzureIdentityBindingName ${var.azure_identity_binding_name} \
      -AzureBindingKubeNamespace ${var.k8s_namespace}
    EOT
  }

  triggers = {
    aks_resource_group_name     = "${var.aks_resource_group_name}"
    kv_reader_identity_name     = "${var.kv_reader_identity_name}"
    azure_identity_name         = "${var.azure_identity_name}"
    azure_identity_binding_name = "${var.azure_identity_binding_name}"
    k8s_namespace               = "${var.k8s_namespace}"
  }

  depends_on = ["null_resource.azure_identity"]
}
