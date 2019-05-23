# Velero Terraform Module

This Terraform module implements Velero restore for a cluster migration scenario. You can use this Terraform module as part of any Terraform plan. It only depends on the existence of a Kubernetes cluster.

Note: This module does not implement Velero backup, contributions are welcome.

Requirements:

* Kubectl
* Bash-compatible shell
* [jq](https://stedolan.github.io/jq/)
* Velero CLI (minimum >1.0)

## Install Velero CLI

There are multiple ways to install the Velero CLI. We strongly recommend that you use an [official release](https://github.com/heptio/velero/releases) of Velero. The tarballs for each release contain the velero command-line client. On OSX, you can use homebrew: `brew install velero`.

There is a dependency on CLI commands that are only available in >v1.0 so please be sure to install >v1.0 or above.

## Cluster Migration: How Restore Works

The module implements restore for a cluster migration using a Terraform resource `velero_restore` that locally executes a bash script with the following process:

1. Velero (server-side) is installed to the Kubernetes cluster with the provided secrets and configuration. Velero is installed in restore-only mode. If Velero is already installed in the cluster, the bash script may override it.
2. Once Velero is installed. The bash script sleeps for at least the backup sync interval (1m) so that the Velero backup resource objects are synchronized from the storage provider. The bash script will attempt to describe the backup using the backup name provided to verify it's existence.
3. If no error is returned, the bash script will create a Velero Restore object with a name from the provided backup.
4. If `velero_install` is set to `true` (which is the default), the bash script will apply an updated Deployment Resource that removes the --restore-only flag.
5. If the `velero_delete_pod` or `velero_uninstall` terraform variables are set to `true`, the bash script will either remove the Velero pod or uninstall Velero completely. See the section below on why you may want to do one of these things.

For an Cluster Migration cenario where:

* You are using Azure.
* You are using Bedrock's Terraform scripts.
* Velero was previously installed in the cluster and is available in the backup.

You must have the following Terraform variables set:

* velero_bucket
* velero_backup_location_config
* velero_volume_snapshot_location_config
* velero_backup_name
* velero_delete_pod="true"
* kubeconfig_complete="${module.aks.kubeconfig_done}"

## Disaster Recovery: How Restore Works

The module implements restore for disaster recovery using a Terraform resource `velero_restore`. For disaster recovery, we assume that the cluster still has a functioning Velero pod and a restore will be performed on the same cluster.

1. The bash script will attempt to describe the backup using the backup name provided to verify it's existence.
2. If no error is returned, the bash script will create a Velero Restore object with a name from the provided backup.

For a Disaster Recovery scenario where:

* You are using Azure.
* You are using Bedrock's Terraform scripts.
* Velero was previously installed in the cluster and is available in the backup

You must have the following Terraform variables set:

* velero_backup_name
* velero_install="false"
* kubeconfig_complete="${module.aks.kubeconfig_done}"

## Terraform Variables

* `output_directory`: Tath to the kubeconfig for the Kubernetes cluster.
* `kubeconfig_filename`: Name of the kubeconfig file saved to disk.
* `kubeconfig_complete`: Variable used to wait for the Kubernetes cluster to be ready.
* `velero_provider`: Set the provider (Azure, AWS, etc.).
* `velero_bucket`: Set the backup storage location bucket.
* `velero_secrets`: The location of the secrets file containing `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`, `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET` & `AZURE_RESOURCE_GROUP` (azure only)". Default set to "./credentials-velero".
* `velero_backup_location_config`: Set the backup storage location config. For Azure, it must have a resourceGroup and storageAccount e.g. `"resourceGroup=<AZURE_RESOURCE_GROUP_NAME>,storageAccount=<AZURE_STORAGE_ACCOUNT_NAME>"`
* `velero_volume_snapshot_location_config`: Set the volume snapshot location config. For Azure, it must have at least apiTimeout e.g. `"apiTimeout=10m"`
* `velero_backup_name`: The name of the backup to restore from.
* `velero_restore_name`: The name of the restore you would like to set. Defaults to `disasterrecoveryrestore`.
* `velero_uninstall`: Uninstall velero after restore is complete. You may want to do this if you don't want velero to be part of your cluster.
* `velero_delete_pod`: Remove the created velero pod but do not uninstall velero. You may want to do this if your backup contains Velero already. Setting this to true makes sure you don't have an extra velero pod running.
