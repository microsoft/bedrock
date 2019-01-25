# Deploying Cluster

This repository contains a set of templates that enable the deployment of infrastructure using
pre-configured Terraform templates.  The `environments` directory contains the base templates for 
doing the deployments.  One can either use them directly or copy / modify as needed.

In order to get started using the templates, the following software must be installed:

- The Azure CLI - [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [terraform](https://www.terraform.io/intro/getting-started/install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

The Azure CLI is necessary to interact with Azure services including the ability to generate a service 
principal.  `terraform` is used to convert the various templates to deployed infrastructure.  `kubectl`
is necessary for interacting with Kubernetes clusters (AKS, etc).

Currently, the following infrastructure examples are defined:

- `environments/azure/aks-flux` is an AKS cluster with [flux](https://github.com/weaveworks/flux-get-started) installed.
- `environments/azure/aks` is a vanilla AKS deployment

As mentioned, one can either work directly with these examples or create a copy for customization.

At a minimum, each of the examples require you determine the following and set variables accordingly.

- `resource_group_name` - this is the name of the resource group one wishes to deploy the infrastructure to
- `cluster_name` - the name of the cluster itself (not the dns / external name)
- `dns_prefix` - the base DNS name for accessing the cluster from the internet
- `service_principal_id`, `service_principal_secret` - the id and secret of the service principal one must generate in order to deploy the AKS cluster.  This is generated using the Azure CLI.
- `ssh_public_key` - the contents of one's public key which is used to access virtual machines within the cluster

To generate the service principal, one issues the command `az ad sp create-for-rbac`, the output resembles:

```bash
{
  "appId": "50d65587-abcd-4619-1234-f99fb2ac0987",
  "displayName": "azure-cli-2019-01-23-20-27-37",
  "name": "http://azure-cli-2019-01-23-20-27-37",
  "password": "3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11",
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

Set `service_principal_id` to `appId` and `service_principal_secret` to `password`.

## Deploying AKS with Flux

[bedrock](https://github.com/Microsoft/bedrock) is meant for creating and deploying clusters to follow
the [Gitops](https://www.weave.works/blog/gitops-operations-by-pull-request) approach of service deployment.

In order to do this, the section describes how to deploy an AKS cluster and install 
[flux](https://github.com/weaveworks/flux-get-started) into the cluster.  Flux is a product from 
Weaveworks which enables [gitops](https://www.weave.works/blog/gitops-operations-by-pull-request) style 
deployment of services into a Kubernetes cluster.  `flux` is installed into the Kubernetes cluster and is 
configured to monitor a specific git repository in which yaml files are deployed.  `flux` takes those yaml 
files and deploys the specified services into the cluster.  Modifications to the cluster that stray from 
those definitions or when new yaml files are deployed to the git repository, `flux` updates the services 
deployed in the cluster.

In addition to the common set of variables defined above, two additional variables are required:

- `gitops_url` - the URL of the Git repository that Flux will monitor for the deployment of services
- `gitops_ssh_key` - the path to the private ssh key that will be used by Flux to access the Git repository

These two variables are generated as part of the prerequisite step outlined in [Setting up Gitops Repository for Flux](#setting-up-gitops-repository-for-flux).

The steps for deploying AKS with `flux`:

1. Change into the `cluster/environments/azure/aks-flux` directory.
2. Issue the command `terraform init`
3. Either edit the `aks-flux.tfvars` file with the variables above (or they can be specified on the command line)
4. The cluster can then be deployed in two different ways:
   - To deploy the cluster using the `aks-flux.tfvars` file: `terraform apply -var-file=./aks-flux.tfvars`
   - To deploy passing variables on the command line:
        ```
        terraform apply -var resource_group_name=my-resource-group \
                    -var cluster_name=my-cluster \
                    -var dns_prefix=mycluster123 \
                    -var service_principal_id=50d65587-abcd-4619-1234-f99fb2ac0987 \
                    -var service_principla_secret=3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11
                    -var ssh_public_key=`cat ~/.ssh/my_azure_key.pub`
                    -var gitops_url=https://github.com/timfpark/fabrikate-cloud-native-materialized
                    -var gitops_ssh_key=~/.ssh/jms-azure-key
        ```
5. After a time, `terraform` will complete and the cluster will be ready.  In order to interact with the deployed Kubernetes cluster, one will need the kube config for that cluster.  That file is placed in the specified `output_directory` which defaults to `./output`.  So, to use it with `kubectl` and see pods deployed, one can simply execute `KUBECONFIG=./output/kube_config kubectl get po --namespace=flux` and show flux running in the cluster.

### Things to Be Aware Of

When deploying clusters, one thing to be aware of is the following:

- `ssh_public_key` must be set to the *contents* of your public key, not the file pointing to the public key.  In the above example, note that `ssh_public_key` is set to the contents, by using `cat` to display what is in the public key file.
- `gitops_ssh_key` must be a path to the *private key file* that was configured to work with the Gitops repository
- `gitops_url` must point to the same repository that the `gitops_ssh_key` was generated / configured as part of the prerequisite steps outline in [Setting up Gitops Repository for Flux](#setting-up-gitops-repository-for-flux).

### Setting Up Gitops Repository for Flux

Flux requires a repository to monitor in order to deploy services to the Kubernetes cluster.  In order to configure 
a repository for use with Flux, the basic steps are as follows:

1.  Create the repo to use for Gitops
2.  Create (or choose) an SSH key pair that will be given permission to do read/write access to the repository
3.  Add the SSH key to the repository

For this example, it is assumed that Github will be used.  Step 1 is just the general process of creating a Github 
repository.  For Step 2, either use an existing SSH key, or to generate an unenxrypted key (using linux), the process resembles:

```bash
tiremunchie:~ jims$ ssh-keygen -b 2048 -t rsa -f gitops_repo_key
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in gitops_repo_key.
Your public key has been saved in gitops_repo_key.pub.
The key fingerprint is:
SHA256:DgAbaIRrET0rM/U5PIT0mcBFVMW/AQ9sRJ/TsdcmmFA jims@tiremunchie
The key's randomart image is:
+---[RSA 2048]----+
|o+Bo=+..*+..E.   |
|oo Xo.o  *..ooo .|
|..+ B+. . =+oo..o|
|.= . B     +. .o |
|. +   + S   o    |
|       o   .     |
|        .        |
|                 |
|                 |
+----[SHA256]-----+
tiremunchie:~ jims$ ls -l gitops_repo_key*
-rw-------  1 jims  staff  1823 Jan 24 16:28 gitops_repo_key
-rw-r--r--  1 jims  staff   398 Jan 24 16:28 gitops_repo_key.pub
```

In order to add the SSH key to the repository, one adds the public key in Github.  That process is documented 
[here](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

## Deploying AKS

If one desires to deploy just a plain AKS cluster, the steps to do so are:

1. Change into the `cluster/environments/azure/aks` directory.
2. Issue the command `terraform init`
3. Either edit the `aks.tfvars` file with the variables above (or they can be specified on the command line)
4. The cluster can then be deployed in two different ways:
   - To deploy the cluster using the `aks.tfvars` file: `terraform apply -var-file=./aks.tfvars`
   - To deploy passing variables on the command line:
        ```
        terraform apply -var resource_group_name=my-resource-group \
                    -var cluster_name=my-cluster \
                    -var dns_prefix=mycluster123 \
                    -var service_principal_id=50d65587-abcd-4619-1234-f99fb2ac0987 \
                    -var service_principla_secret=3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11
                    -var ssh_public_key=`cat ~/.ssh/my_azure_key.pub`
        ```
5. After a time, `terraform` will complete and the cluster will be ready.  In order to interact with the deployed Kubernetes cluster, one will need the kube config for that cluster.  That file is placed in the specified `output_directory` which defaults to `./output`.  So, to use it with `kubectl` and see pods deployed, one can simply execute `KUBECONFIG=./output/kube_config kubectl get po` and show the pods (most likely there will be none)