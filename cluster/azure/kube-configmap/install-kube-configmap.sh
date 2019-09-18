#!/bin/bash
while getopts :n:c:k:v:s: option
do
 case "${option}" in
 n) K8S_NAMESPACE=${OPTARG};;
 c) CONFIG_MAP_NAME=${OPTARG};;
 k) CONFIG_MAP_KEYS=${OPTARG};;
 v) VAULT_NAME=${OPTARG};;
 s) SECRET_NAMES=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

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

SECRET_YAML=$(az keyvault secret show --vault-name $VAULT_NAME --name $SECRET_NAME -o json | jq ".value | @base64d")
if [ -f "/tmp/$NAME.yaml" ]; then
    rm "/tmp/$NAME.yaml"
fi
echo -e "$SECRET_YAML" | sed -e 's/^"//' -e 's/"$//' > "/tmp/$NAME.yaml"

SECRET_NAME_ARRAY=($(echo "$SECRET_NAMES" | tr ',' '\n'))
for ns in "${SECRET_NAME_ARRAY[@]}"
do
    echo "creating secret '$NAME' on namespace '$ns'"
    kubectl apply -n $ns -f "/tmp/$NAME.yaml" --v=5
done
