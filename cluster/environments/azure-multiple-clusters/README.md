# Deploying Multiple Clusters with Traffic Manager in Front

This environment sets up and deploys multiple AKS clusters in Azure with Traffic Manager 
sitting in front of the clusters. 

<this will be expanded with more detail prior to PR>

There are two methods to deploy the environment.  One requires that the Service Principal
you are using has Owner level privileges on the subscriptions.  In many enterprises, this 
will be an unlikely scenario.  The second method does not require these privileges.  The 
difference is, the first grants Role Permissions to the AKS Service Principal such that it
can access a Public IP outside the resource group the AKS cluster is created in.  The second
creates the public IP address for the cluster within the resoruce group that the AKS cluster
is created in.

**This is a placeholder, this repo currently only deploys the second method -- where the Public IP is in the same resource group as the AKS cluster**

Deploying this environment requires a service principal.  To create that service principal, one uses the Azure CLI and issues the following command:

```bash
> az ad sp create-for-rbac
{
  "appId": "4a1dff34-aaaa-bbbb-b62e-dddd5d601a27",
  "displayName": "azure-cli-2019-03-05-01-59-32",
  "name": "http://azure-cli-2019-03-05-01-59-32",
  "password": "5ee46342-eeee-1111-94c1-37c0d6d1cccc",
  "tenant": "abcd88bf-cccc-41af-91ab-2d7cd0111234"
}
```

Now, one uses the above Service Principal for two uses.  First, to set environment variables required
by Terraform to deploy to Azure, to do so, one sets the environment variables as follows:

```bash
export ARM_SUBSCRIPTION_ID=aaaabca0-7a3c-44bd-1234-4bb1e9facccc
export ARM_CLIENT_ID=4a1dff34-aaaa-bbbb-b62e-dddd5d601a27
export ARM_CLIENT_SECRET=5ee46342-eeee-1111-94c1-37c0d6d1cccc
export ARM_TENANT_ID=abcd88bf-cccc-41af-91ab-2d7cd0111234
```

For `ARM_SUBSCRIPTION_ID`, one can find that value by issuing the command `az account show` and grabbing
the value from the output as follows:

```bash
> az account show
{
  "environmentName": "AzureCloud",
  "id": "aaaabca0-7a3c-44bd-1234-4bb1e9facccc",
  "isDefault": true,
  "name": "Playing with Azure",
  "state": "Enabled",
  "tenantId": "abcd88bf-cccc-41af-91ab-2d7cd0111234",
  "user": {
    "name": "anaccount@contoso.com",
    "type": "user"
  }
}
```

Additionall, when editing the `terraform.tfvars` file mentioned below, use `appId` from the Service Principal for `service_principal_id` and `password` for `service_principal_secret`.



In order to get started, one needs to populate the values within the `terraform.tfvars` file
which resembles:

```bash
traffic_manager_profile_name="spinprofile"
traffic_manager_dns_name="spintmdns"
traffic_manager_resource_group_name="global-rg"
traffic_manager_resource_group_location="centralus"

west_resource_group_name="spin-west-rg"
west_resource_group_location="westus2"

east_resource_group_name="spin-east-rg"
east_resource_group_location="eastus2"

central_resource_group_name="spin-central-rg"
central_resource_group_location="centralus"

cluster_name="spincluster"
agent_vm_count = "3"
dns_prefix="spindns"
service_principal_id = "<replace me>"
service_principal_secret = "<replace me>"
ssh_public_key = ""
gitops_url = ""
gitops_ssh_key = ""
```

Once the terraform.tfvars file is populated, like other Terraform deployments, one runs
the commands:

```bash
> terraform init
> terraform apply
```

The cluster will take awhile to deploy.  Once complete, in order to use the public IP address
in Kubernetes, the service definition for each region needs to reference the static IP address
per the instructions [here](https://docs.microsoft.com/en-us/azure/aks/static-ip#create-a-service-using-the-static-ip-address)