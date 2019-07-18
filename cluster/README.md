# Getting Started

Bedrock automates Kubernetes cluster deployments with Terraform to provide full reproducibility of cluster operations.

## Required Tools

Bedrock uses three tools to automate cluster deployments that you'll need to install if you don't already have them:

- [terraform](https://www.terraform.io/intro/getting-started/install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://github.com/helm/helm)

Verify that these tools are added to your system's PATH in order to avoid errors during cluster deployment.  (Note to WSL users: You will need to either move the executables to /usr/local/bin, or modify ~/.bashrc to add them to PATH and persist the new additions across restarts.)

## Follow Cloud Provider Guide

Bedrock provides templates for creating Kubernetes clusters for each supported cloud provider (currently only Azure -- but we would gratefully accept pull requests for other cloud providers).  Follow the instructions for the cloud provider you'd like to create a cluster environment for to get started:

- [Creating a Azure Kubernetes Service (AKS) cluster environment](./azure)
- [Creating a Minikube cluster environment](./minikube

## Incorporating Existing Resources

**IMPORTANT** It is important to note that any resources referenced as a `resource` in Terraform will assume to be managed by Terraform.  So, if one uses an existing cloud resource (resource group, vm, etc) be aware that any updates, changes, or deletions triggered by an operation in Terraform will impact that resource.  For instance, if one were to reference an existing Azure Resource Group and perform `terraform destroy`, the resource group and any resources (even those not managed by Terraform) in that resource group will be deleted.

If you are evaluating Bedrock, it is recommended that you do so in a clean environment.  If you want to use existing resources, please read up one [`terraform import`](https://www.terraform.io/docs/import/index.html).