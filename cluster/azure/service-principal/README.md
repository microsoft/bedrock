# Service Principals and Terraform Deployment

Deploying Bedrock on Azure makes use of Service Princiapals.  Depending on the environment deployed, the Service Principal may require different permission levels or role assignments.  If the service principal being used has `Owner` privileges on the subscription, nothing special needs to be done.  For more information about Service Principals, RBAC and roles check [here](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview).

This document describes a set of tools and requirements necessary to deploy infrastructure in various environments.  Cases addressed include:

- Service principal can be created that has ownership privileges on the subscription
- Service principal will be created with limited privileges within the subscription

Additionally, a separation of service principals will be highlighted, specifically a deployment service principal and an AKS service principal.

## Determining Azure CLI User Role on Subscription

To drive the other sections of the discussion, the role of the user within the subscription will drive what service principal scenarios are possible.  It is assumed that the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) is being used and logged into.  To determine the roles currently available to the logged in user, there is a [script](./scripts/determin_user_subscription.sh) to do such.

For example, running the script locally might look like:

```bash
$ ./determine_user_subscription_roles.sh
User roles for jaspring@microsoft.com on subscription 1234bca0-abcd-44bd-7da2-4bb1e9fa9876:
    - Owner
    - Contributor
jaspring@microsoft.com has Owner level privileges on subscription.
```

## Creating a Service Principal with `Owner` Privileges

A service principal with `Owner` privileges on the subscription has full control on the subscription.  As such, there should be no restrictions on deploying any of the environments.  The only way one can create a service principal with `Owner` is to be an `Owner` one's self.

To create a service principal with `Owner` privileges on subscription `1234bca0-abcd-44bd-7da2-4bb1e9fa9876`, do the following:

```bash
$ az ad sp create-for-rbac --role contributor --scopes /subscriptions/<subscription id>/resourceGroups/<resource group>
{
  "appId": "6e2b7183-7efb-4f82-9250-3bc41234acdb",
  "displayName": "azure-cli-2019-04-11-23-11-42",
  "name": "http://azure-cli-2019-04-11-23-11-42",
  "password": "7b14b018-4d54-4fcb-1234-eb173f5c36c4",
  "tenant": "72f9feeb-86f1-41af-a123-2d7cd0112345"
}
```

There is also a [script](./scripts/create_service_principal_with_subscription_role.sh) to do this.

## Creating a Service Principal with Limited Access on One or More Resources

A frequent scenario will be that a user does not have `Owner` privileges on a subscription, or just as likely, there is a desire to limit the scope of a paritcular service principal.  As mentioned in the [link](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview) above, a service principal can have varying roles to various resources.  Below outlines a couple of likely scenarios:

- [Deploying to a Single Resource Group](#deploy-to-a-single-resource-group)
- [Deploying with Shared Infrastructure](#deploying-with-shared-infrastructure)

### Deploying to a Single Resource Group

A typical enterprise deployment will grant a service principal with access to a restricted set of resources to an individual.  The [azure-simple](../../environments/azure-simple) environment deploys itself to a single resource group.  To set up a service principal addressing this situation, simply create a resource group and provision a service principal with `contributor` access on that service principal.

Assuming a resource group named `bedrockrg1`, the steps to create the resource group and service principal with the proper privileges are as follows:

```bash
$ az group create -n bedrockrg1 -l centralus
{
  "id": "/subscriptions/1234bca0-abcd-44bd-7da2-4bb1e9fa9876/resourceGroups/bedrockrg1",
  "location": "centralus",
  "managedBy": null,
  "name": "bedrockrg1",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": null
}

$ az ad sp create-for-rbac --role Contributor --scopes /subscriptions/1234bca0-abcd-44bd-7da2-4bb1e9fa9876/resourceGroups/bedrockrg1
{
  "appId": "d35a60f3-d6fd-4308-63ee-40e936d29af4",
  "displayName": "azure-cli-2019-04-12-00-34-11",
  "name": "http://azure-cli-2019-04-12-00-34-11",
  "password": "cfd71cba-9194-12a4-8b12-09ccc333fb46",
  "tenant": "72f9feeb-86f1-41af-a123-2d7cd0112345"
}
```

One can also use this [script](./scripts/allocate_resource_group_contributor.sh) to allocate a resource group and a service principal with control of that resource group.

If using a pre-allocated resource group any environment that references the preallocated resource group in an `azurerm_resource_group` snippet will be deleted when one performs a `terraform destroy`.

### Deploying with Shared Infrastructure

The shared infrastructure environments [azure-single-keyvault](../../environments/azure-single-keyvault) and those relying on [azure-common-infra](../../environments/azure-common-infra) perform operations that include adding [Azure Role Assignments](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview) to the service principal specified so that it can access the Azure Keyvault as well as other components.

Granting Role Assignments effectively requires `Owner` privileges on the subscription plus potential other access requirements within Azure Active Directory.  As each enterprise or Active Directory environment may have differing rules, please consult with the Active Directory administrator to determine how best to deploy the environments requiring elevated privileges.
