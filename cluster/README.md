# Getting Started

Bedrock automates Kubernetes cluster deployments with Terraform to provide full reproducibility of cluster operations.

## Required Tools

Bedrock uses three tools to automate cluster deployments that you'll need to install if you don't already have them:

- [terraform](https://www.terraform.io/intro/getting-started/install.html) Bedrock currently uses [Terraform 0.12.6](https://releases.hashicorp.com/terraform/0.12.6/).
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://github.com/helm/helm) - use helm 2.16.1 (stable) because 3.x does not work.

Verify that these tools are added to your system's PATH in order to avoid errors during cluster deployment.  (Note to WSL users: You will need to either move the executables to /usr/local/bin, or modify ~/.bashrc to add them to PATH and persist the new additions across restarts.)

## Releases

To support consistency in the deployment of Terraform based infrastructure.  Bedrock has started implementing releases for Terraform scripts.  The release process and tools for generating a release are found [here](./docs/releases).

The first release(s) is 0.11.0 which will be the basic end of life for Terraform 0.11.x support and 0.12.0 which will be the first release supporting Terraform 0.12.x.

## Follow Cloud Provider Guide

Bedrock provides templates for creating Kubernetes clusters for each supported cloud provider (currently only Azure -- but we would gratefully accept pull requests for other cloud providers).  Follow the instructions for the cloud provider you'd like to create a cluster environment for to get started:

- [Creating a Azure Kubernetes Service (AKS) cluster environment](./azure)
- [Creating a Minikube cluster environment](./minikube)

## Incorporating Existing Resources

**IMPORTANT** It is important to note that any resources referenced as a `resource` in Terraform will assume to be managed by Terraform.  So, if one uses an existing cloud resource (resource group, vm, etc) be aware that any updates, changes, or deletions triggered by an operation in Terraform will impact that resource.  For instance, if one were to reference an existing Azure Resource Group and perform `terraform destroy`, the resource group and any resources (even those not managed by Terraform) in that resource group will be deleted.

If you are evaluating Bedrock, it is recommended that you do so in a clean environment.  If you want to use existing resources, please read [`terraform import`](https://www.terraform.io/docs/import/index.html).
