# Bedrock on Azure

## Summary

To get started with Bedrock on Azure, perform the following steps create an Azure Kubernetes Service (AKS) cluster using Terraform. 

- [Install required tools](#install-required-tools)
- [Set up GitOps repository for Flux](../../common/flux/)
- [Azure Cluster Deployment](##Azure-Cluster-Deployment)

## Install required tools

As a first step, make sure you have installed the [pre-requisite tools](../README.md) on your machine.

Additionally, you need the Azure `az` command line tool in order to create and fetch Azure configuration info:

- [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Azure Cluster Deployment

Bedrock currently have the following templates that you can choose to deploy in your Azure subscription by following template specific documentation.

- [azure-simple](../environments/azure-simple/): Single cluster deployment.
- [azure-multiple-clusters](../environments/azure-multiple-clusters/): Multiple clusters  deployment with Traffic Manager.
- [azure-advanced](../environments/azure-advanced): Single cluster deployment with Azure Keyvault integration through flex volumes.

