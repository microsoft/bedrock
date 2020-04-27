# Deploying Single Cluster with Keyvault 

If you followed our first workload walkthrough you saw how Bedrock enables you to scaffold and generate Terraform deployment scripts. In the first workload walkthrough, to demonstrate a simple GitOps workflow, we deployed a simple cluster using Azure Simple Terraform template. However in the real world, in order to have secure deployments, we need a way to store the essential secrets in Keyvault. In addition, we will also deploy a vnet to provide isolation to our cloud infrastructure. 

In upcoming advanced scenarios, we will be using the Bedrock automation to repeat the cluster creation process by scaffolding configurations to deploy multiple clusters. Since all these clusters use common resources like Keyvault, Storage Account and a Vnet, we will deploy these resources using azure-common-infra template. The environment provisioned using this template is a dependency for other environments (azure-single-keyvualt) we will be using in the subsequent walkthroughs.

Note: This walkthrough assumes that you already have set all the environment variables as part of [first walkthrough](firstWorkload/README.md). 

## Deplying the common infrastructure:

Before you deploy infrastructure environments, you will need to create an Azure Storage Account. You can do this in Azure Portal, or by using the Azure CLI:

### Resource Group Requirement:

This environment requires a resource group. The requisite variable is `global_resource_group_name`.  To use the Azure CLI to create the resource group [see common commands](https://github.com/microsoft/bedrock/blob/master/cluster/azure/README.md).

To create a resource group, you can use the following command 

```
$ az group create -l westus2 -n my-global-rg
```

### Create Storage Account in Azure:

Before attempting to deploy the infrastructure environments, you will also need to create an Azure Storage Account. You can do this in Azure Portal, or by using the Azure CLI:

```
az storage account create \
    --name mystorageaccount \
    --resource-group my-global-rg \
    --location eastus \
    --sku Standard_LRS \
    --encryption-services blob
```

The Azure CLI needs your storage account credentials for most of the commands in this tutorial. While there are several options for doing so, one of the easiest ways to provide them is to set `AZURE_STORAGE_ACCOUNT` and `AZURE_STORAGE_KEY` environment variables.

First, display your storage account keys by using the az storage account keys list command:

```
az storage account keys list \
    --account-name mystorageaccount \
    --resource-group my-global-rg \
    --output table
```

Now, set the `AZURE_STORAGE_ACCOUNT` and `AZURE_STORAGE_KEY` environment variables. You can do this in the Bash shell by using the export command:

```
export AZURE_STORAGE_ACCOUNT="mystorageaccount"
export AZURE_STORAGE_KEY="myStorageAccountKey"
```

Blobs are always uploaded into a container. You can organize groups of blobs similar to the way you organize your files on your computer in folders.

Create a container for storing blobs with the az storage container create command.

```
az storage container create --name mystoragecontainer
```

Next, let's create a folder called azure-common-infra
```
mkdir azure-common-infra 
cd azure-common-infra
```
Next, use Bedrock cli command to scaffold the configuration for common-infra template using the following command. Here we are using the Bedrock’s predefined `azure-common-infra` template to create configuration parameters for westus cluster. 

```
bedrock infra scaffold --name westus --source https://github.com/microsoft/bedrock --version master --template cluster/environments/azure-common-infra
```

This `scaffold` command creates a directory called `westus` and creates a definition.yaml file in it that looks like this:

```yaml
name: westus
source: 'https://github.com/microsoft/bedrock'
template: cluster/environments/azure-common-infra
version: master
backend:
  storage_account_name: <storage account name>
  access_key: <storage access key>
  container_name: <storage account container>
  key: tfstate-common-infra
variables:
  address_space: <insert value>
  keyvault_name: <insert value>
  global_resource_group_name: <insert value>
  service_principal_id: <insert value>
  subnet_name: <insert value>
  subnet_prefix: <insert value>
  vnet_name: <insert value>
```
`scaffold` has downloaded the template locally, extracted all of the variables for the template, and provided defaults where possible for all of the variables.

Let's fill in the variables for common-infra infrastructure variables. 
Note: `global_resource_group_name' is the resource group that was created in the [Resource Group Requirement](#Resource-Group-Requirement:).

```yaml
name: westus
source: 'https://github.com/microsoft/bedrock'
template: cluster/environments/azure-common-infra
version: master
backend:
  storage_account_name: 'mystorageaccount'
  access_key: 'CENp3G0...hjvetWsD+Drw=='
  container_name: 'mystoragecontainer'
  key: tfstate-common-infra
variables:
  address_space: '10.8.0.0/16'
  keyvault_name: 'mykeyvault'
  global_resource_group_name: 'my-global-rg'
  service_principal_id: '91896545-0aa8-4444-5555-111461be44a6'
  subnet_name: 'mysubnet'
  subnet_prefix: '10.8.0.0/24'
  vnet_name: 'myvnet'
```
Now that we have these variables filled in, we will use 'bedrock infra generate' command to generate terraform tfvars file that we will use to provision the infrastructure. 

Navigate to `azure-common-infra/westus` folder and run the following command.

```
bedrock infra generate -p westus
```
This command creates westus-generated directory inside azure-common-infra directory. Navigate to `azure-common-infra/westus-generated` directory. Notice that this directory has terraform variable files. 

Let's provision the common infrastructure by running the following commands from this folder 

```
terraform init -backend-config=./backend.tfvars
terraform plan -var-file=bedrock.tfvars
```
If the plan succeeds, run the following command 
```
terraform apply -var-file=bedrock.tfvars
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
...
```
This should provision keyvault, vnet in your azure subscription. 

You can reuse the common infrastructure components for multiple clusters.

## Deplying Azure Single Cluster with Keyvault:

Now that we have common infrastructure components in place, we are ready to deploy AKS cluster using Bedrock Azure Single Cluster with Keyvault environment. The `azure-single-keyvault` environment deploys a single production level AKS cluster configured with Flux and Azure Keyvault.

### Resource Group Requirement:

This environment requires another resource group be created.  The requisite variable is `resource_group_name`.  To use the Azure CLI to create the resource group, see [here](https://github.com/microsoft/bedrock/blob/master/cluster/azure/README.md).

To create a resource group, you can use the following command 

```
$ az group create -l westus2 -n my-cluster-rg
```
Next, to scaffold infrastructure, we will use `bedrock infra scaffold` command at the root level and the cluster level

At the same level as your azure-common-infra directory, run the following command

```
bedrock infra scaffold --name azure-single-keyvault --source https://github.com/microsoft/bedrock --version master --template cluster/environments/azure-single-keyvault
```
This creates a directory named azure-single-keyvault and places global defintion.yaml inside the directory. Now, navigate to this directory and create cluster specific configurations by running the following commnad

```
$cd azure-single-keyvault
$bedrock infra westus --name azure-single-keyvault --source https://github.com/microsoft/bedrock --version master --template cluster/environments/azure-single-keyvault
```
This creates a subdirectory named westus inside `azure-single-keyvault` directory. Navigate to this directory and open definition.yaml file

```yaml


name: azure-single-keyvault
source: 'https://github.com/microsoft/bedrock'
template: cluster/environments/azure-single-keyvault
version: master
backend:
  storage_account_name: storage-account-name
  access_key: storage-account-access-key
  container_name: storage-account-container
  key: tfstate-key
variables:
  acr_enabled: 'true'
  address_space: <insert value>
  agent_vm_count: <insert value>
  agent_vm_size: <insert value>
  cluster_name: <insert value>
  dns_prefix: <insert value>
  flux_recreate: <insert value>
  gc_enabled: 'true'
  gitops_poll_interval: 5m
  gitops_label: flux-sync
  gitops_ssh_url: <insert value>
  gitops_url_branch: master
  gitops_ssh_key: <insert value>
  gitops_path: <insert value>
  keyvault_name: <insert value>
  keyvault_resource_group: <insert value>
  kubernetes_version: 1.15.7
  resource_group_name: <insert value>
  ssh_public_key: <insert value>
  service_principal_id: <insert value>
  service_principal_secret: <insert value>
  subnet_prefixes: <insert value>
  vnet_name: <insert value>
  subnet_name: <insert value>
  network_plugin: azure
  network_policy: azure
  oms_agent_enabled: 'false'
  enable_acr: 'false'
  acr_name: <insert value>
```

Next we'll fill all of the empty items in this template with config values.
Note: Use `storage_account_name`, `access_key` , `container_name`, `keyvault_name`, `keyvault_resource_group` and `vnet_name` from the previous [Deploying common infrastructure](#Deploying-common-infrastructure:) step. 

Here, we will be using the manifest repo you created for the first workload. However, let's copy the manifest file from the root directory to a subdirectory called `prod`

Navigate to your devops repo folder that you cloned from [first walkthrough](../Firstworkload/README.md). Create a subdirectory named prod and copy azure-vote-all-in-one-redis.yaml to that subdirectory. In a future walkthrough, we can have different subdirectories for each cluster with slight variations to the manifest. This step is in preparation for future walkthroughs. 

```
$ mkdir prod
$ cp azure-vote-all-in-one-redis.yaml
$ git add .
$ git commit -m "copy manifest to new folder"
$ git push origin master
```

```yaml
name: cluster
source: 'https://github.com/microsoft/bedrock'
template: cluster/environments/azure-single-keyvault
version: master
backend:
  storage_account_name: 'mystorageaccount'
  access_key: 'CENp3G0qvo4jB1HduRO10ga0jNrN+b4gMibuAp63qZBDRNzXYZrP7dUu8XM4lca6HL4RobXCfhjvAAAAAbbbb=='
  container_name: 'mystoragecontainer'
  key: tfstate-single-keyvault
variables:
  acr_name: 'jhansiacr2'
  agent_vm_count: '3'
  agent_vm_size: Standard_D2s_v3
  acr_enabled: 'true'
  gc_enabled: 'true'
  cluster_name: 'bedrock-aks2'
  dns_prefix: 'bedrock'
  flux_recreate: 'false'
  gitops_ssh_url: 'git@ssh.dev.azure.com:v3/myorg/app-cluster-manifests'
  gitops_path: 'prod'
  gitops_ssh_key: '~/cluster-deployment/keys'
  gitops_url_branch: master
  keyvault_name: 'mykeyvault'
  keyvault_resource_group: 'my-global-rg'
  resource_group_name: 'my-cluster-rg'
  ssh_public_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUcBzqjBc59Ypa+Y2Cc9z+wDldZnSEGoJt+sUbux/KrczQmHmKqpdW50zMSY4MYhdfJsn902mZad4qOVj/KvQwwl7cGyWqzK+yEw/CrgqCX9wzloJrq75M1V3Qaaaaaaaaaaaaabbbbbbb91lnmtzGyOIJJlHoxm4TPR8tRhWeAcb6mRBKOeGQSSNekyi08dtYhYHlWFXaSZzqVevgiNYCGkcgXbPE1fE6Da2SAmOdBwANCHE8OZXnh yourname@org.com'
  gitops_poll_interval: 2m
  gitops_label: flux-sync
  vnet_name: 'myvnet'
  service_principal_id: '46b1b7dc-168a-ccc-bbb-aaaaaaa'
  service_principal_secret: 'aaaa-bbbb-43eb-9ead-dddddd'
  kubernetes_version: '1.15.7'
  subnet_name: 'mysubnet'
  subnet_prefix: 10.8.0.0/24
  network_plugin: azure
  network_policy: azure
  oms_agent_enabled: 'yes'
  ```
Navigate to azure-single-keyvault folder and use the following command to generate terraform variables using `bedrock`.

```
$cd ~/azure-single-keyvault
$bedrock infra generate -p westus 
```
bedrock reads our definition.yaml file, downloads the template referred to in it, applies the parameters we have provided, and creates a generated Terraform script in a directory called azure-single-keyvault-generated which is at the same level as azure-single-keyvault folder. Navigate to azure-single-keyvault-generated/westus folder. Now you are ready to provision the cluster using Terraform 

```
$terraform init -backend-config=./backend.tfvars -var-file=bedrock.tfvars
```
Our next step is to plan the deployment, which will preflight our deployment script and the configured variables, and output the changes that would happen in our infrastructure if applied:

```
$terraform plan -var-file=bedrock.tfvars
```

Finally, once plan shows no errors, we can apply the changes 

```
$terraform apply -var-file=bedrock.tfvars
...
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
...
```
It will take few miniutes to get the cluster deployed. 

### Interacting with deployed cluster:

The `azure-single-keyvault` Terraform template we used in this walkthrough automatically copies the Kubernetes config file from the cluster into the output directory. This config file has all of the details we need to interact with our new cluster.

To utilize it, we first need to merge it into our own config file and make it the default configuration. We can do that with this:

$ KUBECONFIG=./output/bedrock_kube_config:~/.kube/config kubectl config view --flatten > merged-config && mv merged-config ~/.kube/config

With this, you should be able to see the pods running in the cluster:

```
NAMESPACE     NAME                                    READY   STATUS    RESTARTS   AGE
default       azure-vote-back-77dff7bbd5-xlxxf        1/1     Running   0          3h50m
default       azure-vote-front-7f7c8c5766-8xpdh       1/1     Running   0          3h50m
flux          flux-5997784678-s8qvc                   1/1     Running   0          3h51m
flux          flux-memcached-6547454f96-w9dz5         1/1     Running   0          3h51m
kube-system   azure-cni-networkmonitor-8b57g          1/1     Running   0          3h53m
kube-system   azure-cni-networkmonitor-lrdhg          1/1     Running   0          3h53m
kube-system   azure-cni-networkmonitor-tssrz          1/1     Running   0          3h53m
kube-system   azure-ip-masq-agent-74jg4               1/1     Running   0          3h53m
kube-system   azure-ip-masq-agent-76vsj               1/1     Running   0          3h53m
kube-system   azure-ip-masq-agent-n47j9               1/1     Running   0          3h53m
kube-system   azure-npm-dndnw                         1/1     Running   0          3h53m
kube-system   azure-npm-nd6l7                         1/1     Running   0          3h53m
kube-system   azure-npm-q59w5                         1/1     Running   0          3h53m
kube-system   coredns-698c77c5d7-h2pwp                1/1     Running   0          3h52m
kube-system   coredns-698c77c5d7-vqgvf                1/1     Running   0          3h56m
kube-system   coredns-autoscaler-79b778686c-qqknv     1/1     Running   0          3h56m
kube-system   kube-proxy-n2sdl                        1/1     Running   0          33m
kube-system   kube-proxy-z2md2                        1/1     Running   0          33m
kube-system   kube-proxy-zgl4f                        1/1     Running   0          33m
kube-system   kubernetes-dashboard-74d8c675bc-7zk84   1/1     Running   0          3h56m
kube-system   metrics-server-69df9f75bf-hhzgj         1/1     Running   0          3h56m
kube-system   tunnelfront-865f7d9f5d-wb4xx            1/1     Running   0          3h56m
kv            keyvault-flexvolume-jld5p               1/1     Running   0          3h51m
kv            keyvault-flexvolume-qc5tp               1/1     Running   0          3h51m
kv            keyvault-flexvolume-szbc8               1/1     Running   0          3h51m
```
You can get external IP by running the following command

```
$ kubectl get services --all-namespaces
NAMESPACE     NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)         AGE
default       azure-vote-back        ClusterIP      10.0.182.151   <none>         6379/TCP        4h15m
default       azure-vote-front       LoadBalancer   10.0.30.238    35.889.68.30   80:32100/TCP    4h15m
default       kubernetes             ClusterIP      10.0.0.1       <none>         443/TCP         4h21m
flux          flux                   ClusterIP      10.0.195.4     <none>         3030/TCP        4h16m
flux          flux-memcached         ClusterIP      10.0.226.253   <none>         11211/TCP       4h16m
kube-system   kube-dns               ClusterIP      10.0.0.10      <none>         53/UDP,53/TCP   4h21m
kube-system   kubernetes-dashboard   ClusterIP      10.0.172.46    <none>         80/TCP          4h21m
kube-system   metrics-server         ClusterIP      10.0.208.44    <none>         443/TCP         4h21m
```

External load balancers like this take time to provision. If the EXTERNAL-IP of service is still pending, keep trying periodically until it is provisioned.

The EXTERNAL-IP, in the case above, is: 35.889.68.30. By appending the port our service is hosted on we can use http://35.889.68.30:80 to fetch the service in a browser.

![voting app](../firstWorkload/images/voting-app-deployed-in-azure-kubernetes-service.png)

Congratulations, you have successfully deployed a Azure Kubernetes Cluster with Keyvault using this walkthrough.


 
