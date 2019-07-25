# azure-velero-restore

The `azure-velero-restore` environment defines a template for a cluster that includes stateful workloads that you want to restore. This environment restores a single production level AKS cluster from a Velero backup using the Velero Terraform module.

Assumptions:

* You had a Velero install in your previous cluster with a successful backup completed. (See Fabrikate definition for [Velero](https://github.com/microsoft/fabrikate-definitions/tree/master/definitions/fabrikate-velero))
* You have successfully backed up persistent volumes.
* You had Flux installed in your cluster and it is backed up correctly.

Depending on the scenario - Disaster Recovery or Cluster Migration - you will want to follow the appropriate instructions in the Velero Terraform Module [README](../../common/velero/README.md). In particular, set the appropriate terraform variables for your scenario as well as the desired state for Velero (e.g. uninstalled?) once a restore is complete.

## When To Use This Environment - Typical Flow

You would use this environment to restore a single production AKS cluster if one has gone bad. Your typical flow should be to use `azure-common-infra` and `azure-single-keyvault` (Support for `azure-multiple-cluster` is coming soon) to set up your initial cluster. You would then add `Velero` as a component to your fabrikate definition and setup a schedule backup. If you experience a cluster failure or a disaster (e.g. someone deleted your cluster). You would then use this environment to spin up a new cluster with the same variables as your initial `azure-single-keyvault` but add the velero restore specific variables to restore from a backup.
