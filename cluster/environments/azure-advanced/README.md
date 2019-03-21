## Getting started with azure-advanced environment

The `azure-advanced` builds upon the `azure-simple` environment and adds the following funcitonality:

- Provisions an [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/)
- Configure Key Vault support within the AKS cluster making use of [Kubernetes Key Vault Flex Volume](https://github.com/Azure/kubernetes-keyvault-flexvol)

To deploy the `azure-advanced` environment, follow the [common steps](../../azure/) taking into account the additional configuration required for each of the added components:

- [Azure Key Vault](#azure-key-vault)
- [Kubernetes Key Vault Flex Volume](#kubernetes-key-vault-flex-volume)

Additional variables that can be configured for `azure-advanced`, see [variables.tf](./variables.tf).

*NOTE*: Because the deployment of Flex Volume requires additional [Azure Role Assignments](https://docs.microsoft.com/en-us/rest/api/authorization/roleassignments) be created.  The Service Principal provisioned as part of the [common setup](../../azure/README.md#create-an-azure-service-principal) is required to have `Owner` level privileges on the subscription.

### Azure Key Vault

[Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) is a secure repository for secets, keys, and certificates.  Within this environment, it is used to store and manage secrets that could be used by the AKS deployment itself or applications running within the cluster.  In order to configure Azure Key Vault in this environment, the following additional variables must be definted:

- `keyvault_name`: this is a unique name for the Key Vault.  Per [this doc](https://docs.microsoft.com/en-us/azure/key-vault/about-keys-secrets-and-certificates), Key Vault names are are globally unique and must be a 3-24 character string, containing only 0-9, a-z, A-Z, and -.
- `secret_name`: the name of a secret to create within the Key Vault
- `secret_value`: the value of the secret to be stored within the Key Vault

### Kubernetes Key Vault Flex Volume

The [Kubernetes Key Vault Flex Volume](https://github.com/Azure/kubernetes-keyvault-flexvol) is a mechanism for exposing secrets securely stored within Azure Key Vault to applications running within the AKS cluster.  There are two components to working with the Flex Volume.  First, Flex Volume support must be installed within the cluster, which is what is done within this `azure-advanced` environment.  Second, applications deployed within the AKS cluster need to be configured to request to expose particular secrets.  This is handled on an application by application basis and is documented on the Flex Volume [project page](https://github.com/Azure/kubernetes-keyvault-flexvol).

*NOTE*: Flex Volume support is installed using Service Principal based access.

There are no additional variables required by the addition of Key Vault Flex Volume support.

