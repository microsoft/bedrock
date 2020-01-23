# A First Workload With Bedrock

The best way to start learning about Bedrock is walk through the deployment of a cluster and a first workload on it, enabling you to see how Bedrock makes deploying infrastructure easier and how GitOps works first hand.

In this walkthrough, we will:
1. Create our GitOps resource manifest repo that will act as the source of truth for our in-cluster deployments.
2. Scaffold, generate, and deploy our first infrastructure deployment.
3. Make our first GitOps commit and see those changes deployed in the cluster by Flux.

## Create and Configure GitOps Resource Manifest Repo

In a GitOps workflow, a git repo is the source of truth of what should be deployed in our cluster. An operator in the Kubernetes cluster (Flux in the case of Bedrock) watches this repo and applies changes as they are made to the cluster such that the resources in the cluster exactly match the GitOps resource manifest repo.

Our next step is to create and configure this repo for this workflow.

### Create the Flux Manifest Repository

[Create an empty git repository](https://github.com/new/), choose a name that shows the repo is used for a GitOps workflow (eg.  `app-cluster-manifests`) and then clone it locally:

```bash
$ git clone https://github.com/myuser/app-cluster-manifests
```

Initialize the repo with an empty commit:

``` bash
$ cd app-cluster-manifests
$ git commit --allow-empty -m "Initializing GitOps Resource Manifest Repository"
$ git push origin master
```

### Generate an Deploy Key for the GitOps Resource Manifest Repo

Flux pushes a tag to the git repo to track the last commit it has reconciled against once it finishes its reconcilitation of a commit. This operation requires authentication such that the repo can validate that Flux is authorized to push these tags.

For a Github repo, an SSH key is used for authentication.

To create a GitOps SSH key:
1. Create a separate directory to store they key and other infrastructure deployment items:

```bash
$ mkdir -p ~/cluster-deployment
```

2. Create a key pair for the GitOps workflow:

```bash
$ mkdir -p ~/cluster-deployment/keys
$ ssh-keygen -b 4096 -t rsa -f ~/cluster-deployment/keys/gitops-ssh-key
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/myuser/.ssh/gitops-ssh-key.
Your public key has been saved in /Users/myuser/.ssh/gitops-ssh-key.pub.
The key fingerprint is:
SHA256:jago9v63j05u9WoiNExnPM2KAWBk1eTHT2AmhIWPIXM myuser@computer.local
The key's randomart image is:
+---[RSA 4096]----+
|.=o.B= +         |
|oo E..= .        |
|  + =..oo.       |
|   . +.*o=       |
|    o . S..      |
|   . * . .       |
|... o ... .      |
|...  .o+.. .     |
|  .o..===o.      |
+----[SHA256]-----+
```

This creates the private and public keys for our GitOps workflow:
1. Private key: for Flux to authenticate against the GitOps repo
2. Public key: for the GitOps repo to validate the passed credentials.

The public key will be uploaded to GitHub as a deploy key. The private key will be used during the cluster deployment of Flux.

### Add Deploy Key to the Manifest Repository
Prerequisites:
- Ownership permissions to the git repo

Steps:
1. Copy the contents of the public key to your clipboard:

**MacOS**

```bash
$ pbcopy < ~/cluster-deployment/keys/gitops-ssh-key.pub
```

**Ubuntu (including WSL)**

```bash
$ cat ~/cluster-deployment/keys/gitops-ssh-key.pub | xclip
```

2. On the Github repository, select `Settings` -> `Deploy Keys` -> `Add deploy key`. Set the title and paste the contents of the public key. Check the  **Allow Write Access** option.


![enter key](./images/addDeployKey.png)

3. Click "Add key", and you should see:

![key result](./images/deployKeyResult.png)

## Scaffold Cluster Deployment

With our GitOps resource manifest repo and key pair created, let’s move on to scaffolding out our cluster deployment.

Creating, managing, and maintaining infrastructure deployment templates is a challenge, especially at scale. Large scale deployments can consist of dozens of nearly identical clusters differentiated only by slight differences in config based on the cloud region they are operating in or otherwise.

Bedrock helps manage this complexity with infrastructure environment templates and definitions. Let’s see this in action by scaffolding out our first definition with Bedrock’s `spk` command line tool:

```bash
$ cd ~/cluster-deployment
$ spk infra scaffold --name cluster --source https://github.com/microsoft/bedrock --version master --template cluster/environments/azure-simple
```

This fetches the specified deployment template, creates a `cluster` directory, and places a `definition.yaml` file in it:

```yaml
name: cluster
source: 'https://github.com/microsoft/bedrock'
template: cluster/environments/azure-simple
version: master
variables:
  agent_vm_count: '3'
  agent_vm_size: Standard_D2s_v3
  acr_enabled: 'true'
  gc_enabled: 'true'
  cluster_name: <insert value>
  dns_prefix: <insert value>
  flux_recreate: 'false'
  gitops_ssh_url: <insert value>
  gitops_ssh_key: <insert value>
  gitops_path: <insert value>
  gitops_url_branch: master
  resource_group_name: <insert value>
  ssh_public_key: <insert value>
  service_principal_id: <insert value>
  service_principal_secret: <insert value>
  gitops_poll_interval: 5m
  gitops_label: flux-sync
  vnet_name: <insert value>
  service_cidr: 10.0.0.0/16
  dns_ip: 10.0.0.10
  docker_cidr: 172.17.0.1/16
  address_space: 10.10.0.0/16
  subnet_prefix: 10.10.1.0/24
  network_plugin: azure
  network_policy: azure
  oms_agent_enabled: 'false'
```

This `definition.yaml` is our first infrastructure definition.  It contains a reference to a deployment template that is maintained by the Bedrock project in this case -- but this template could exist anywhere.

This template is the base of our deployment. Note: The `spk` tool also extracted the variables for this Terraform template and provided them, with defaults (if available).

## Completing our Deployment Definition

Next we'll fill all of the empty items in this template with config values.

### Cluster name, DNS prefix, VNET name, and resource group

Choose a cluster name (for example: `myname-cluster`) and replace both `cluster_name` and `dns_prefix` with this. This will be the name of the cluster to be created in your subscription.

Update the value for `resource_group_name` to be a variant of this, like `myname-cluster-rg`, and update `vnet_name` with a variant as well, like `myname-vnet`. Your cluster will be created in this resource group and VNET.

### Configure GitOps Repo

Update the `gitops_ssh_url` to your GitOps resource manifest repo, using the `ssh` url format available when you clone the repo from Github. For example: `git@github.com:myuser/app-cluster-manifests.git`.

Set the `gitops_ssh_key` to the GitOps private key we created previously. If you followed those steps, you can set this value to `../keys/gitops-ssh-key`.

In multi-cluster scenarios, we will often keep all of the resource manifests for all of our clusters in the same repo, but in this simple case, we are only managing one cluster, so we are going to use the root of our GitOps repo as our root for our in-cluster resource manifests.

Given this, make `gitops_path` an empty string `""`.

### Create an Azure Service Principal

Our deployment specification includes references to values for the [Azure Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) for the [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/) cluster:

```
    service_principal_id: ""
    service_principal_secret: ""
```

For this walkthrough, we will use one Service Principal to deploy with Terraform and for the AKS cluster itself.

1. [login to the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli):

```bash
$ az login
```

2. Get the id for your subscription:

```bash
$ az account show
{
  "environmentName": "AzureCloud",
  "id": "7060bca0-1234-5-b54c-ab145dfaccef",
  "isDefault": true,
  "name": "Fabrikam Subscription",
  "state": "Enabled",
  "tenantId": "72f984ed-86f1-41af-91ab-87acd01ed3ac",
  "user": {
    "name": "olina@fabrikam.io",
    "type": "user"
  }
}
```

3. Create the Service Principal (using the subscription id above):

```bash
$ mkdir -p ~/cluster-deployment/sp
$ az ad sp create-for-rbac --scopes "/subscriptions/7060bca0-1234-5-b54c-ab145dfaccef" > ~/cluster-deployment/sp/sp.json
$ cat ~/cluster-deployment/sp/sp.json
{
  "appId": "7b6ab9ae-dead-abcd-8b52-0a8ecb5beef7",
  "displayName": "azure-cli-2019-06-13-04-47-36",
  "name": "http://azure-cli-2019-06-13-04-47-36",
  "password": "35591cab-13c9-4b42-8a83-59c8867bbdc2",
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

Since these are sensitive secrets, we are going to use environment variables to pass them into our deployment to avoid accidentially checking them in.  Given this, create the following environment variables using the following mapping:

```bash
$ export ARM_SUBSCRIPTION_ID=(subscription id from above)
$ export ARM_TENANT_ID=(tenant from Service Principal)
$ export ARM_CLIENT_SECRET=(password from Service Principal)
$ export ARM_CLIENT_ID=(appId from Servive Principal)
```

Using the values from above, these environment variables would look like:

```bash
$ export ARM_SUBSCRIPTION_ID=7060bca0-1234-5-b54c-ab145dfaccef
$ export ARM_TENANT_ID=72f984ed-86f1-41af-91ab-87acd01ed3ac
$ export ARM_CLIENT_SECRET=35591cab-13c9-4b42-8a83-59c8867bbdc2
$ export ARM_CLIENT_ID=7b6ab9ae-dead-abcd-8b52-0a8ecb5beef
```

3. In the `definition.json`, delete `service_principal_id` and `service_principal_secret`

4. Define the `service_principal_id` and `service_principal_secret` environment variables:

```bash
$ export TF_VAR_service_principal_id=7b6ab9ae-dead-abcd-8b52-0a8ecb5beef
$ export TF_VAR_service_principal_secret=35591cab-13c9-4b42-8a83-59c8867bbdc2
```

Documentation about Service Principals is available in the [Bedrock documentation](https://github.com/microsoft/bedrock/tree/master/cluster/azure#create-an-azure-service-principal).

### Create a Node Key

When you deploy an AKS cluster, you provide an SSH key pair that enables you, in rare circumstances, to shell into the nodes of the cluster.

1. We’ll use the same process that we used to create a key pair for GitOps:

```bash
$ ssh-keygen -b 4096 -t rsa -f ~/cluster-deployment/keys/node-ssh-key
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/myuser/cluster-deployment/keys/node-ssh-key.
Your public key has been saved in /home/myuser/cluster-deployment/keys/node-ssh-key.pub.
The key fingerprint is:
SHA256:+8pQ4MuQcf0oKT6LQkyoN6uswApLZQm1xXc+pp4ewvs myuser@computer.local
The key's randomart image is:
+---[RSA 4096]----+
|   ...           |
|  . o. o .       |
|.. .. + +        |
|... .= o *       |
|+  ++ + S o      |
|oo=..+ = .       |
|++ ooo=.o        |
|B... oo=..       |
|*+. ..oEo..      |
+----[SHA256]-----+
```

2. Copy the public key for this node key pair into your clipboard using the same method you did for the GitOps public key:

**MacOS**
```bash
$ pbcopy < ~/cluster-deployment/keys/node-ssh-key.pub
```

**Ubuntu (& WSL)**
```bash
$ cat ~/cluster-deployment/keys/node-ssh-key.pub | xclip
```

3. Paste this into your `definition.json` file as the value for `ssh_public_key`.

### Create Azure Resource Group

You will need a resource group in your subscription before you do a `terraform apply`.

To create a resource group:

```bash
$ az group create -l westus2 -n myuser-cluster-rg
```
### Generate Terraform Deployment

With these prep steps completed, let’s generate Terraform templates from this cluster definition directory:

```bash
$ cd ~/cluster-deployment
$ spk infra generate -p cluster
```

This reads our `definition.json` file, downloads the template referred to in it, applies the parameters we have provided, and creates a generated Terraform script in a directory called `cluster-generated`.

## Deploy Cluster

From this `generated` directory we can `init` our Terraform deployment to fetch all of the upstream Terraform module dependencies.

```bash
$ terraform init
Initializing modules...
Downloading github.com/microsoft/bedrock?ref=0.12.0//cluster/azure/aks-gitops for aks-gitops...
- aks-gitops in .terraform/modules/aks-gitops/cluster/azure/aks-gitops
- aks-gitops.aks in .terraform/modules/aks-gitops/cluster/azure/aks
- aks-gitops.aks.azure-provider in .terraform/modules/aks-gitops/cluster/azure/provider
- aks-gitops.aks.azure-provider.common-provider in .terraform/modules/aks-gitops/cluster/common/provider
- aks-gitops.flux in .terraform/modules/aks-gitops/cluster/common/flux
- aks-gitops.flux.common-provider in .terraform/modules/aks-gitops/cluster/common/provider
- aks-gitops.kubediff in .terraform/modules/aks-gitops/cluster/common/kubediff
- aks-gitops.kubediff.common-provider in .terraform/modules/aks-gitops/cluster/common/provider
Downloading github.com/microsoft/bedrock?ref=0.12.0//cluster/azure/provider for provider...
- provider in .terraform/modules/provider/cluster/azure/provider
- provider.common-provider in .terraform/modules/provider/cluster/common/provider
Downloading github.com/microsoft/bedrock?ref=0.12.0//cluster/azure/vnet for vnet...
- vnet in .terraform/modules/vnet/cluster/azure/vnet

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "null" (hashicorp/null) 2.1.2...
- Downloading plugin for provider "random" (hashicorp/random) 2.2.1...
- Downloading plugin for provider "azuread" (hashicorp/azuread) 0.5.1...
- Downloading plugin for provider "azurerm" (hashicorp/azurerm) 1.32.1...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Our next step is to plan the deployment, which will preflight our deployment script and the configured variables, and output the changes that would happen in our infrastructure if applied:

```bash
$ terraform plan -var-file=spk.tfvars
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.azurerm_resource_group.cluster_rg: Refreshing state...
module.aks-gitops.data.azurerm_resource_group.aksgitops: Refreshing state...
module.vnet.data.azurerm_resource_group.vnet: Refreshing state...
module.aks-gitops.module.aks.data.azurerm_resource_group.cluster: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.vnet.azurerm_subnet.subnet[0] will be created
  + resource "azurerm_subnet" "subnet" {
      + address_prefix       = "10.10.1.0/24"
      + id                   = (known after apply)
      + ip_configurations    = (known after apply)
      + name                 = "myuser-cluster-aks-subnet"
      + resource_group_name  = "myuser-cluster-rg"
      + service_endpoints    = []
      + virtual_network_name = "myuser-cluster-vnet"
    }

.... snip ....

Plan: 8 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

Finally, since we are happy with these changes, we apply the Terraform template.

$ terraform apply -var-file=spk.tfvars
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + azurerm_resource_group.cluster_rg
      id:                                         <computed>
      location:                                   "westus2"
      name:                                       "myuser-cluster-rg"
      tags.%:                                     <computed>

... snip ...

Plan: 8 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.vnet.azurerm_resource_group.vnet: Creating...
  location: "" => "westus2"
  name:     "" => "testazuresimplerg"
  tags.%:   "" => "<computed>"
azurerm_resource_group.cluster_rg: Creating...
  location: "" => "westus2"
  name:     "" => "testazuresimplerg"
  tags.%:   "" => "<computed>"

.... snip ...

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.
```

You have successfully have deployed your first cluster with Bedrock!

This might seem like a lot of overhead for creating a single cluster. The real advantage of this comes when you need to manage multiple clusters that are only slightly differentiated by config, or when you want to do upgrades to a new version of the template, and a variety of other “day 2” scenarios. You can read in detail about these scenarios in our infrastructure definitions documentation.

### Using Terraform State

Terraform stores the results of our `terraform apply` in a `terraform.tfstate` file. You can see an overview of resources created with:

```bash
$ terraform state list
azurerm_resource_group.cluster_rg
module.aks-gitops.module.aks.azurerm_kubernetes_cluster.cluster
module.aks-gitops.module.aks.azurerm_resource_group.cluster
module.aks-gitops.module.aks.null_resource.cluster_credentials
module.aks-gitops.module.flux.null_resource.deploy_flux
module.vnet.azurerm_resource_group.vnet
module.vnet.azurerm_subnet.subnet
module.vnet.azurerm_virtual_network.vnet
````

You can see more details about any one of these created resources with:

```bash
$ terraform state show module.vnet.azurerm_virtual_network.vnet
id                     = /subscriptions/b59451c1-cd43-41b3-b3a4-74155d8f6cf6/resourceGroups/tst-az-simple-rg/providers/Microsoft.Network/virtualNetworks/testazuresimplevnet
address_space.#        = 1
address_space.0        = 10.10.0.0/16
ddos_protection_plan.# = 0
dns_servers.#          = 0
location               = westus2
name                   = testazuresimplevnet
resource_group_name    = tst-az-simple-rg
subnet.#               = 0
tags.%                 = 1
tags.environment       = azure-simple
```

And a full set of details with:

```bash
$ terraform show
```

### Interacting with the Deployed Cluster

The `azure-simple` Terraform template we used in this walkthrough automatically copies the Kubernetes config file from the cluster into the `output` directory.  This config file has all of the details we need to interact with our new cluster.

To utilize it, we first need to merge it into our own config file and make it the default configuration.  We can do that with this:

```bash
$ KUBECONFIG=./output/bedrock_kube_config:~/.kube/config kubectl config view --flatten > merged-config && mv merged-config ~/.kube/config
```

With this, you should be able to see the pods running in the cluster:

```bash
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
flux          flux-5698f45759-ntnz5                  1/1     Running   0          10m
flux          flux-memcached-7c9c56b487-wcsvr        1/1     Running   0          10m
kube-system   azure-cni-networkmonitor-7bjwt         1/1     Running   0          13m
kube-system   azure-cni-networkmonitor-h7m64         1/1     Running   0          13m
kube-system   azure-cni-networkmonitor-q7hn2         1/1     Running   0          13m
kube-system   azure-ip-masq-agent-2xtng              1/1     Running   0          13m
kube-system   azure-ip-masq-agent-5v6vz              1/1     Running   0          13m
kube-system   azure-ip-masq-agent-jpb5h              1/1     Running   0          13m
kube-system   azure-npm-l5flr                        2/2     Running   1          13m
kube-system   azure-npm-qsxnq                        2/2     Running   0          13m
kube-system   azure-npm-zs8hz                        2/2     Running   0          13m
kube-system   coredns-7fc597cc45-7m7cm               1/1     Running   0          11m
kube-system   coredns-7fc597cc45-q2kr8               1/1     Running   0          18m
kube-system   coredns-autoscaler-7ccc76bfbd-pfwjh    1/1     Running   0          18m
kube-system   kube-proxy-c8p2j                       1/1     Running   0          13m
kube-system   kube-proxy-tnrd2                       1/1     Running   0          13m
kube-system   kube-proxy-wsqhn                       1/1     Running   0          13m
kube-system   kubernetes-dashboard-cc4cc9f58-qjbc2   1/1     Running   0          18m
kube-system   metrics-server-58b6fcfd54-c2w6x        1/1     Running   0          18m
kube-system   tunnelfront-5787f6d67-f84zn            1/1     Running   0          18m
```

As you can see, Flux was provisioned as part of cluster creation, and we can see the pods are running in the cluster.

Copying the name of the flux pod, let’s fetch the logs for it:

```bash
$ kubectl logs flux-5897d4679b-tckth -n flux
ts=2019-06-18T06:33:18.668235584Z caller=main.go:193 version=1.12.2
ts=2019-06-18T06:33:18.781628775Z caller=main.go:350 component=cluster identity=/etc/fluxd/ssh/identity
ts=2019-06-18T06:33:18.781698175Z caller=main.go:351 component=cluster identity.pub="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTNdGpnmztWRa8RofHl8dIGyNkEayNR6d7p2JtJ7+zMj0HRUJRc+DWvBML4DvT29AumVEuz1bsVyVS2f611NBmXHHKkbzAZZzv9gt2uB5sjnmm7LAORJyoBEodR/T07hWr8MDzYrGo5fdTDVagpoHcEke6JT04AL21vysBgqfLrkrtcgaXsw8e3rkfbqGLbhb6o1muGdEyE+uci4hRVj+FGL9twh3Mb6+0uak/UsTFgfDi/oTXdXOFIitQ1o40Eip6P4xejEOuIye0cg7rfX461NmOP7HIEsUa+BwMExiXXsbxj6Z0TXG0qZaQXWjvZF+MfHx/J0Alb9kdO3pYx3rJbzmdNFwbWM4I/zN+ng4TFiHBWRxRFmqJmKZX6ggJvX/d3z0zvJnvSmOQz9TLOT4lqZ/M1sARtABPGwFLAvPHAkXYnex0v93HUrEi7g9EnM+4dsGU8/6gx0XZUdH17WZ1dbEP7VQwDPnWCaZ/aaG7BsoJj3VnDlFP0QytgVweWr0J1ToTRQQZDfWdeSBvoqq/t33yYhjNA82fs+bR/1MukN0dCWMi7MqIs2t3TKYW635E7VHp++G1DR6w6LoTu1alpAlB7d9qiq7o1c4N+gakXSUkkHL8OQbQBeLeTG1XtYa//A5gnAxLSzxAgBpVW15QywFgJlPk0HEVkOlVd4GzUw=="
ts=2019-06-18T06:33:18.781740875Z caller=main.go:352 component=cluster host=https://10.0.0.1:443 version=kubernetes-v1.13.5
ts=2019-06-18T06:33:18.781823975Z caller=main.go:364 component=cluster kubectl=/usr/local/bin/kubectl
ts=2019-06-18T06:33:18.783257271Z caller=main.go:375 component=cluster ping=true
ts=2019-06-18T06:33:18.790498551Z caller=main.go:508 url=git@github.com:jmspring/manifests.git user="Weave Flux" email=support@weave.works signing-key= sync-tag=flux-sync notes-ref=flux set-author=false
ts=2019-06-18T06:33:18.790571551Z caller=main.go:565 upstream="no upstream URL given"
ts=2019-06-18T06:33:18.791840947Z caller=main.go:586 addr=:3030
ts=2019-06-18T06:33:18.819345472Z caller=loop.go:90 component=sync-loop err="git repo not ready: git repo has not been cloned yet"
ts=2019-06-18T06:33:18.819404372Z caller=images.go:18 component=sync-loop msg="polling images"
```

## Deploy an update using Kubernetes manifest

The GitOps workflow we established with Flux and Bedrock makes it easy to control the workflow that is running in the cluster. Flux watches the GitOps resource manifest repo and applies any changes we make there to the cluster.

Let’s try this by creating a YAML file with a set of Kubernetes resources for a simple service and committing it to the resource manifest repo. In your resource manifest git repo directory that we cloned earlier, create a file called `webapp.yaml` and place the following into it:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mywebapp
  labels:
    app: mywebapp
spec:
  type: LoadBalancer
  ports:
  - port: 8080
    name: http
  selector:
    app: mywebapp
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: mywebapp-v1
spec:
  replicas: 3
  minReadySeconds: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    metadata:
      labels:
        app: mywebapp
        version: v1
    spec:
      containers:
      - name: mywebapp
        image: andrebriggs/goserver:v1.2
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
---
```

This defines a 3 pod deployment of a web service with the container `andrebriggs/goserver:v1.2` with a LoadBalanced service.  Commit this file and push it to our remote GitOps repo:

```bash
$ git add webapp.yaml
$ git commit -m "Add simple web application"
$ git push origin master
```

Watch the Flux pod logs again, but this time tailing them so we get updates with `-f`:

```bash
$ kubectl logs flux-5897d4679b-tckth -n flux -f
```

Once Flux starts its next reconcilation, we see at the end of the output that Flux found the repo `bedrock-deploy-demo` and created the new service:

`"kubectl apply -f -" took=1.263687361s err=null output="service/mywebapp created\ndeployment.extensions/mywebapp-v1 created"`.

Once applied, we should be able to see the web app pods running in our cluster:

```bash
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
mywebapp-v1-749d754b4f-k55pv   1/1     Running   0          18m
mywebapp-v1-749d754b4f-nshj5   1/1     Running   0          18m
mywebapp-v1-749d754b4f-sj2hf   1/1     Running   0          18m
```

We should also see the LoadBalancer service by querying the set of services in the cluster:

```
$ kubectl get services --all-namespaces
NAMESPACE     NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE
default       kubernetes             ClusterIP      10.0.0.1       <none>           443/TCP          44m
default       mywebapp               LoadBalancer   10.0.96.208    52.175.216.214   8080:30197/TCP   23m
flux          flux                   ClusterIP      10.0.139.133   <none>           3030/TCP         34m
flux          flux-memcached         ClusterIP      10.0.246.230   <none>           11211/TCP        34m
kube-system   kube-dns               ClusterIP      10.0.0.10      <none>           53/UDP,53/TCP    44m
kube-system   kubernetes-dashboard   ClusterIP      10.0.222.104   <none>           80/TCP           44m
kube-system   metrics-server         ClusterIP      10.0.189.185   <none>           443/TCP          44m
```

External load balancers like this take time to provision. If the EXTERNAL-IP of service is still pending, keep trying periodically until it is provisioned.

The EXTERNAL-IP, in the case above, is: 52.175.216.214. By appending the port our service is hosted on we can use http://52.175.216.214:8080 to fetch the service in a browser.

![Deployed Web application running](./images/WebAppRunning.png)

And that’s it. We have created a GitOps resource manifest repo, scaffolded and deployed an AKS cluster, and used GitOps to deploy a web app workload to it.

As a final step, you probably want to delete your Kubernetes cluster to save on your wallet. Thankfully, Terraform has a command for that:

```bash
$ cd ~/cluster-deployment/cluster-generated
$ terraform destroy -var-file=spk.tfvars
```
