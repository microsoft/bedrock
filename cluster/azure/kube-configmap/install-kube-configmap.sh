#!/bin/bash
while getopts :a:b:n:c:k:v:s: option
do
 case "${option}" in
 a) AKS_SUBSCRIPTION_ID=${OPTARG};;
 b) VAULT_SUBSCRIPTION_ID=${OPTARG};;
 n) K8S_NAMESPACE=${OPTARG};;
 c) CONFIG_MAP_NAME=${OPTARG};;
 k) CONFIG_MAP_KEYS=${OPTARG};;
 v) VAULT_NAME=${OPTARG};;
 s) SECRET_NAMES=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ -z $AKS_SUBSCRIPTION_ID ]; then
    echo "AKS_SUBSCRIPTION_ID is empty"
    exit 1
else
    echo "AKS_SUBSCRIPTION_ID=$AKS_SUBSCRIPTION_ID"
fi
if [ -z $VAULT_SUBSCRIPTION_ID ]; then
    echo "VAULT_SUBSCRIPTION_ID is empty"
    exit 1
else
    echo "VAULT_SUBSCRIPTION_ID=$VAULT_SUBSCRIPTION_ID"
fi
if [ -z $K8S_NAMESPACE ]; then
    echo "K8S_NAMESPACE is empty"
    exit 1
else
    echo "K8S_NAMESPACE=$K8S_NAMESPACE"
fi
if [ -z $CONFIG_MAP_NAME ]; then
    echo "CONFIG_MAP_NAME is empty"
    exit 1
else
    echo "CONFIG_MAP_NAME=$CONFIG_MAP_NAME"
fi
if [ -z $CONFIG_MAP_KEYS ]; then
    echo "CONFIG_MAP_KEYS is empty"
    exit 1
else
    echo "CONFIG_MAP_KEYS=$CONFIG_MAP_KEYS"
fi
if [ -z $VAULT_NAME ]; then
    echo "VAULT_NAME is empty"
    exit 1
else
    echo "VAULT_NAME=$VAULT_NAME"
fi
if [ -z $SECRET_NAMES ]; then
    echo "SECRET_NAMES is empty"
    exit 1
else
    echo "SECRET_NAMES=$SECRET_NAMES"
fi

az account set -s $VAULT_SUBSCRIPTION_ID
SECRET_NAME_ARRAY=($(echo "$SECRET_NAMES" | tr ',' '\n'))
CONFIG_MAP_KEY_ARRAY=($(echo "$CONFIG_MAP_KEYS" | tr ',' '\n'))

for name in "${SECRET_NAME_ARRAY[@]}"
do
    echo "downloading file '$name' from vault '$VAULT_NAME'"
    if [ -f "/tmp/$name" ]; then
        rm "/tmp/$name"
    fi
    az keyvault secret download --vault-name $VAULT_NAME --name $name --file "/tmp/$name"
done

args=""
for i in "${!CONFIG_MAP_KEY_ARRAY[@]}"; do
    key=${CONFIG_MAP_KEY_ARRAY[i]}
    filename=${SECRET_NAME_ARRAY[i]}
    file="/tmp/$filename"
    arg="--from-file=$key=$file "
    echo "arg=$arg"
    args+=$arg
done

az account set -s $AKS_SUBSCRIPTION_ID
cmd="kubectl create configmap $CONFIG_MAP_NAME -n $K8S_NAMESPACE $args"
echo "cmd=$cmd"

if ! kubectl describe namespace $K8S_NAMESPACE > /dev/null 2>&1; then
    echo "Creating k8s namespace $K8S_NAMESPACE"
    if ! kubectl create namespace $K8S_NAMESPACE; then
        echo "ERROR: failed to create kubernetes namespace $K8S_NAMESPACE"
    fi
fi

if kubectl describe configmap "$CONFIG_MAP_NAME" -n $K8S_NAMESPACE > /dev/null 2>&1; then
    echo "Configmap already exist, try remove it"
    if ! kubectl delete configmap "$CONFIG_MAP_NAME" -n $K8S_NAMESPACE > /dev/null 2>&1; then
        echo "Warning: failed to delete previous configmap, retry"
    else
        echo "Removed previous configmap: $CONFIG_MAP_NAME"
    fi
fi

eval $cmd