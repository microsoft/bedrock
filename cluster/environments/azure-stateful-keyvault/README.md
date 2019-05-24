# azure-stateful-keyvault

The `azure-stateful-keyvault` environment defines a template for a cluster that includes stateful workloads that you want to backup and restore. This environment restores a single production level AKS cluster from a Velero backup using the Velero Terraform module.

Assumptions:

* You already have a Velero install in your Cluster with a successful backup. (See Fabrikate definition for [Velero](https://github.com/microsoft/fabrikate-definitions/tree/master/definitions/fabrikate-velero))
* You have successfully backed up persistent volumes.

Depending on the scenario - Distaster Recovery or Cluster Migration - you will want to follow the appropriate instructions in the Velero Terraform Module [README](../../common/velero/README.md). In particular, set the appropriate terraform variables for your scenario as well as the desired state for Velero (e.g. uninstalled?) once a restore is complete.
