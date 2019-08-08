#!/bin/sh
while getopts :r:a:u: option
do
 case "${option}" in
 r) ROLE_NAME=${OPTARG};;
 a) ADMIN_RBAC_FILE=${OPTARG};;
 u) USER_RBAC_FILE=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ "$ROLE_NAME" = "cluster_admin" ]; then
    echo "Assign dashboard to cluster_admin"
    kubectl apply -f $ADMIN_RBAC_FILE
else
    echo "Assign dashboard to cluster_reader"
    kubectl apply -f $USER_RBAC_FILE
fi
