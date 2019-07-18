# Getting Started

Bedrock automates Kubernetes cluster deployments with Terraform to provide full reproducibility of cluster operations.

## Required Tools

Bedrock assumes that you have a deployment computer or VM running Unix or Linux and a bash shell. Beyond that, it uses three main tools to automate cluster deployments that you'll need to install if you don't already have them:

- [terraform v0.11.14](https://releases.hashicorp.com/terraform/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/using_helm/#installing-helm)

Terraform v0.12 is not supported yet, so ensure that your environment has v0.11. Please do not install these packages with `snap` or other package installers - they can create issues when using `sudo`. Follow the instructions to use `curl` for all of them. Verify that these tools are added to your deployment system's PATH by printing your path or typing their names in the console in order to avoid errors during cluster deployment.  (Note to WSL users: You may need to either move the executables to /usr/local/bin, or modify ~/.bashrc to add them to PATH and persist the new additions across restarts.)

## Follow Cloud Provider Guide

Bedrock provides templates for creating Kubernetes clusters for each supported cloud provider (currently only Azure -- but we would gratefully accept pull requests for other cloud providers).  Follow the instructions for the cloud provider on which you'd like to create your cluster environment to get started:

- [Creating a Azure Kubernetes Service (AKS) cluster environment](./azure)
- [Creating a Minikube cluster environment](./minikube)
