#!/bin/bash
while getopts :v:s:n:m: option
do
 case "${option}" in
 v) VAULT_NAME=${OPTARG};;
 s) SECRET_NAME=${OPTARG};;
 n) NAME=${OPTARG};;
 m) NAMESPACES=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ -z $VAULT_NAME ]; then
    echo "VAULT_NAME is empty"
    exit 1
else
    echo "VAULT_NAME=$VAULT_NAME"
fi
if [ -z $SECRET_NAME ]; then
    echo "SECRET_NAME is empty"
    exit 1
else
    echo "SECRET_NAME=$SECRET_NAME"
fi
if [ -z $NAME ]; then
    echo "NAME is empty"
    exit 1
else
    echo "NAME=$NAME"
fi
if [ -z $NAMESPACES ]; then
    echo "NAMESPACES is empty"
    exit 1
else
    echo "NAMESPACES=$NAMESPACES"
fi

SECRET_YAML=$(az keyvault secret show --vault-name $VAULT_NAME --name $SECRET_NAME -o json | jq ".value" | base64 --decode)
echo $SECRET_YAML

NAMESPACE_ARRAY=($(echo "$NAMESPACES" | tr ',' '\n'))
for ns in "${NAMESPACE_ARRAY[@]}"
do
    echo -e $SECRET_YAML | kubectl apply -n $ns -f -
done