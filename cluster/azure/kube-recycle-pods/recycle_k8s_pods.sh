#!/bin/bash
while getopts :n: option
do
 case "${option}" in
 n) K8SNS=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ -z $K8SNS ]; then
    echo "K8SNS is empty"
    exit 1
else
    echo "K8SNS=$K8SNS"
fi

PODS=$(kubectl get po -n $K8SNS -o json)
PODS_NAMES=$(echo "$PODS" | jq '.items[].metadata.name' | sed -e 's/^"//' -e 's/"$//')
PODS_NAME_ARRAY=($(echo "$PODS_NAMES" | tr ',' '\n'))
 for p in "${PODS_NAME_ARRAY[@]}"
do
    kubectl delete pod $p -n $K8SNS
done