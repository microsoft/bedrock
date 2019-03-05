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