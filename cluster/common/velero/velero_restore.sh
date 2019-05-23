#!/usr/bin/env bash

while getopts :b:p:s:l:v:n:r:u:d:i: option
do
 case "${option}" in
 b) VELERO_BUCKET=${OPTARG};;
 p) VELERO_PROVIDER=${OPTARG};;
 s) VELERO_SECRETS=${OPTARG};;
 l) VELERO_BACKUP_LOCATION_CONFIG=${OPTARG};;
 v) VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG=${OPTARG};;
 n) VELERO_BACKUP_NAME=${OPTARG};;
 r) VELERO_RESTORE_NAME=${OPTARG};;
 i) VELERO_INSTALL=${OPTARG};;
 u) VELERO_UNINSTALL=${OPTARG};;
 d) VELERO_DELETE_POD=${OPTARG};;
 *) echo "ERROR: Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if ! hash velero 2>/dev/null; then
    echo "'velero' was not found in PATH. Please install the velero cli before running terraform."
    exit 1
fi

if [ -z "$VELERO_BACKUP_NAME" ] || [ -z "$VELERO_RESTORE_NAME" ]; then
    echo "ERROR: 'VELERO_BACKUP_NAME' or 'VELERO_RESTORE_NAME' is not set or set to an empty string."
    exit 1
fi

# Velero install is only needed in a cluster migration scenario. Skip for clusters that already have Velero.
if [ "$VELERO_INSTALL" == "true" ]; then
    # Check Azure Specific settings
    if [ -z "$VELERO_PROVIDER" ] && [ "$VELERO_PROVIDER" == "azure" ]; then
        if [ -z "$VELERO_SECRETS" ] && test -e "$VELERO_SECRETS"; then
            echo "ERROR: 'VELERO_SECRETS' is not set or does not exist but is required for the azure provider."
            exit 1
        fi

        if [[ "$VELERO_BACKUP_LOCATION_CONFIG" =~ "resourceGroup=" ]] && [[ "$VELERO_BACKUP_LOCATION_CONFIG" =~ "storageAccount=" ]]; then
            echo "'VELERO_BACKUP_LOCATION_CONFIG' contains the resourceGroup and storageAccount variable."
        else
            echo "ERROR: 'VELERO_BACKUP_LOCATION_CONFIG' does not have a resourceGroup or storageAccount variables set."
            exit 1
        fi

        if [[ "$VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG" =~ "apiTimeout=" ]]; then
            echo "'VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG' contains the apiTimeout variable."
        else
            echo "ERROR: 'VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG' does not have an apiTimeout variables set."
            exit 1
        fi
    fi
    # TODO: Check AWS/GCP specific settings here.

    # Setup Velero on Cluster to do Restore
    echo "Installing Velero."

    velero install \
        --provider "$VELERO_PROVIDER" \
        --bucket "$VELERO_BUCKET" \
        --secret-file "$VELERO_SECRETS" \
        --backup-location-config "$VELERO_BACKUP_LOCATION_CONFIG" \
        --snapshot-location-config "$VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG" \
        --restore-only \
        --wait

    velero_install_result=$?
    if [ $velero_install_result -ne 0 ]; then
        echo "ERROR: Velero failed to install."
        exit 1
    fi

    echo "Waiting for Velero resources to be synchronized. Default is 1min."
    sleep 1m

    VELERO_POD_NAME=$(kubectl get pods -n velero -o jsonpath="{.items[].metadata.name}")

    echo "Velero Pod Name: $VELERO_POD_NAME"
fi

if ! velero backup describe "$VELERO_BACKUP_NAME"; then
    echo "ERROR: Failed to find backup with name $VELERO_BACKUP_NAME."
    exit 1
fi

echo "Attempting to restore from $VELERO_BACKUP_NAME with restore name: $VELERO_RESTORE_NAME."
velero restore create "$VELERO_RESTORE_NAME" --from-backup "$VELERO_BACKUP_NAME" --wait

velero_restore_result=$?
if [ $velero_restore_result -ne 0 ]; then
    echo "ERROR: Velero failed to restore backup. See: $velero_restore_result"
    exit 1
fi

if [ "$VELERO_INSTALL" == "true" ]; then
    # This is needed because there is currently no documented way to remove the restore-only flag
    # using the CLI. There is no guarantee that Velero was in the backup either or that the backup 
    # flips the flag so we remove it. Not sure if there is a better way to do this.
    echo "Remove Velero restore-only flag from deployment"
    velero install \
        --provider "$VELERO_PROVIDER" \
        --bucket "$VELERO_BUCKET" \
        --secret-file "$VELERO_SECRETS" \
        --backup-location-config "$VELERO_BACKUP_LOCATION_CONFIG" \
        --snapshot-location-config "$VELERO_VOLUME_SNAPSHOT_LOCATION_CONFIG" \
        --dry-run --output json | jq '.items[] | select(.kind=="Deployment")' | kubectl replace -f -
fi

if [ "$VELERO_INSTALL" == "true" ] && [ "$VELERO_DELETE_POD" == "true" ]; then
    echo "Velero delete pod is set to $VELERO_DELETE_POD so running kubectl delete to $VELERO_POD_NAME"
    kubectl -n velero delete pod "$VELERO_POD_NAME"
fi

if [ "$VELERO_UNINSTALL" == "true" ]; then
    echo "Velero uninstall set to $VELERO_UNINSTALL so uninstalling velero."
    kubectl delete namespace/velero clusterrolebinding/velero
    kubectl delete crds -l component=velero
fi
