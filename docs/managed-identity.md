# Managed Identity

This document is intended to give an overview of using [Managed Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) (MI) with [Azure Kubernetes Service](https://azure.microsoft.com/en-us/services/kubernetes-service/) (AKS).

MI is a common alternative to [Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) based authentication because it provides services with an automatically managed identity in Azure AD. Applications can use the identity to authenticate to any service that supports Azure AD authentication, including Key Vault, without any credentials in code or the environment.

## AKS Managed Identities

AKS natively supports MI ([docs](https://docs.microsoft.com/en-us/azure/aks/use-managed-identity)). Azure automatically creates a [System Assigned Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview#managed-identity-types) for AKS deployments that leverage MI.

Infrastructure deployed through Terraform can leverage an `identity` block ([ref](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#identity)) to deploy a cluster with Managed Identity.

### Required Role Assignments

#### ACR Pull

Grants AKS MI the ability to pull application images from ACR

```hcl
resource "azurerm_role_assignment" "acrpull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_id
}
```

## Pod Managed Identities

AAD Pod Identity enables Kubernetes applications to access cloud resources securely with Azure Active Directory (AAD).

Using Kubernetes primitives, administrators configure identities and bindings to match pods. Then without any code modifications, your containerized applications can leverage any resource in the cloud that depends on AAD as an identity provider.

### Required Role Assignments

The following Role Assignments are required based on the [AAD Pod Identity](https://github.com/Azure/aad-pod-identity/blob/master/docs/readmes/README.role-assignment.md) documentation:

#### Managed Identity Operator

Grant AKS MI the ability to read and assign User Assigned MI

```hcl
resource "azurerm_role_assignment" "mi_operator" {
  scope                = data.azurerm_resource_group.kube_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.aks.kubelet_id
}
```

#### Virtual Machine Contributor

Grant AKS MI the ability to manage VMs in AKS VM Scale Set 

```hcl
resource "azurerm_role_assignment" "vm_contrib" {
  scope                = data.azurerm_resource_group.kube_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = module.aks.kubelet_id
}
```

#### Other

Pod MIs will also need access to other Azure Managed Services. Here is an example of what that might look like:

```hcl
# Example: grant Pod MI access to Azure Storage
resource "azurerm_role_assignment" "mi_container" {
  count                = length(local.identities_for_storage)
  scope                = azurerm_storage_container.example.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = local.identities_for_storage[count.index].principal_id
}
```

### Installing AAD Pod Identity on AKS

AAD Pod Identity can be installed on AKS using Helm. The [official documentation](https://github.com/Azure/aad-pod-identity#1-deploy-aad-pod-identity) details the steps needed.
