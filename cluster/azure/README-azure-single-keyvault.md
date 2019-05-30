## Azure Single Key Vault

The next part is to deploy an azure-single-keyvault environment. This deployment is responsible for creating a Kubernetes cluster, configures Flux, and integrates Key Management Systems with Kubernetes via a FlexVolume.

Like the azure-common-infra environment, you will need to copy the template ti an appropriate first:

`$ cp -r cluster/environments/azure-single-keyvault cluster/environments/<your new cluster name>`

The azure-single-keyvault will utilize the backend.tfvars and will require that you create a consumable .tfvars (e.g. terraform.tfvars) that looks like the following:

backend.tfvars (NOTE: you can and should use the same backend.tfvars that was used in the azure-common-infra, but with a different key as shown below):

```
storage_account_name="myStorageAccount"

access_key="gmnNFIa/LyKgbC5CZn9Io8jbngSW+Isa5vTZfKsIgkz/8EG2YPn4CV42hMDXmQ73zDu5Y7puFkAoWPHLtE6/mw=="

container_name="myContainer"

key="tfstate-single-keyvault"

terraform.tfvars:

#--------------------------------------------------------------

# keyvault, vnet, and subnets are created seperately by azure-common-infra

#--------------------------------------------------------------

keyvault_name = "yradsmikvault"

keyvault_resource_group = "yradsmik-rg"

address_space = "10.39.0.0/16"

subnet_prefixes = "10.39.0.0/24"

vnet_name = "yradsmikvnet"

vnet_subnet_id = "/subscriptions/7060bca0-7a3c-44bd-b54c-4bb1e9facfac/resourceGroups/yradsmik-rg/providers/Microsoft.Network/virtualNetworks/spinvnet/subnets/spinsubnet"

#--------------------------------------------------------------

# Cluster variables

#--------------------------------------------------------------

agent_vm_count = "3"

agent_vm_size = "Standard_D4s_v3"

cluster_name = "my-single-keyvault-cluster"

dns_prefix = "my-single-keyvault"

gitops_ssh_url = "git@github.com:yradsmikham/fabrikate-production-cluster-demo-materialized"

gitops_ssh_key = "./gitops_repo_key"

resource_group_name = "my-single-keyvault-rg"

resource_group_location = "westus2"

ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaIIB9KC1ugvvXUEXVUHE2KblsA16g80AkYLDPkFAE8SNTBN8hlZj+2TFPCoxbjxaZiAtRuohbgsfKKioZOQRow9U4y/ytzSRPzxgPseFQWosCIo6zWCskH25tm9NoEK2m80zgjBDY7fCtnHV8MQVZdWc0Qitz8PMox3rBtAykZoTIlG5G7iF2L/BJJUe1hpXHhNDrh/JG3TAc6J6XmCSqUaUyu4PDaTDyrW9aStUt0bkyK6RDYxZBBb0ssEWOtmFWRxsXx+f5WrHR+B+UaINS503O2isSw6ItsfKtwjjBHcx7qO90nzlVML+PpPOZSdXI4D/ftTvrVKyPjF7TEwXj yvonneradsmikham@Yvonnes-MBP.guest.corp.microsoft.com"

service_principal_id = "dd6c3524-0f34-4b69-8c18-546e63a6a83f"

service_principal_secret = "ed30a164-0785-487b-bdc2-02d677fbda43"

subscription_id = "7060bca0-7a3c-44bd-b54c-4bb1e9facfac"

tenant_id = "72f988bf-86f1-41af-91ab-2d7cd011db47"

#--------------------------------------------------------------

# Optional variables - Uncomment to use

#--------------------------------------------------------------

# gitops_url_branch = "release-123"

# gitops_poll_interval = "30s"

# gitops_path = "prod"
```

To deploy the azure-single-keyvault environment, run the following commands in your environment directory:

```
terraform init -backend-config=./backend.tfvars
terraform apply -var-file=./terraform.tfvars
```

Upon deployment of the cluster, one artifact that the terraform scripts generate is the credentials necessary for logging into the AKS cluster that was deployed. These credentials are placed in the location specified by the variable “output_directory”. For single cluster environments, this defaults to .”/output”.

With the default kube config file name, you can copy this to your ~/.kube/config by executing:

`$ KUBECONFIG=./output/bedrock_kube_config:~/.kube/config kubectl config view --flatten > merged-config && mv merged-config ~/.kube/config`

It is also possible to use the config that was generated directly. For instance, to list all the pods within the flux namespace, run the following:

`$ KUBECONFIG=./output/bedrock_kube_config kubectl get po --namespace=flux`

It is possible to verify the health of the AKS cluster deployment by looking at the status of the flux pods that were deployed. A standard deployment of flux creates two pods flux and flux-memcached. To check the status, enter the command:

```
kubectl get pods --namespace=flux
```

The pods should be deployed, and if in a healthy state, should be in a Running status. The output should resemble:

```
NAME                              READY   STATUS    RESTARTS   AGEflux-568b7ccbbc-qbnmv             1/1     Running   0          8m07sflux-memcached-59947476d9-d6kqw   1/1     Running   0          8m07s
```

If the Flux pod shows a status other than 'Running' (e.g. 'Restarting...'), it likely indicates that it is unable to connect to your GitOps repo. In this case, verify that you have assigned the correct public key to the GitOps repo (with write privileges) and that you have specified the matching private key in your Terraform configuration.
