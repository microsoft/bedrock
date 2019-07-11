# Azure Kubernetes Service Deployment Options

Using Terraform to interact with Azure, there are options on how to manage one's deployments.  This document is a collection of those options that don't necessarily fit within other portions of the document.  Topics include:

- [Using an Existing Resource Group](#using-an-existing-resource-group)

## Using An Existing Resource Group

Any object that is referred to as a `resource` in a Terraform script will be managed by Terraform and tracked as part of the `tfstate` file during deployment.  This means, if you were to use an existing `resource_group` as part of one of the environment deployments (for instance specifying the `resource_group_name` in [azure-simple](../environments/azure-simple/)) when one performed `terraform destroy`, Terraform will remove the specified resource group.

In order to get around this, each of the Bedrock environments have been modified to allow for deployment into an existing `resource_group` without impacting that `resource group` upon the execution of `terraform destroy`.  In order to do this, each environment has a variable similar to the name `resource_group_preallocated`.  This value must be set to `true` in order to operate on an existing `resource group` without risking deletion of that `resource group` when destory operations are performed.  The name of the variable differs slightly per environment and in the case of environments with multiple resource groups, there will be a corresponding `*_preallocated` variable for each of the resource groups.

So for instance, in the case of `azure-simple`, the relevant portion of the `terraform.tfvars` file for resource group definition would resemble:

```bash
resource_group_name="thisisanexistingresourcegroup"
resource_group_preallocated="true"
resource_group_location="westus2"
```

Note that `resource_group_location` is still specified, but this value will be ignored and the actual location of the existing resource group will be used.
