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

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

echo "Running on $machine"
if [ "$machine" == "Mac" ]; then
    SECRET_YAML=$(az keyvault secret show --vault-name $VAULT_NAME --name $SECRET_NAME -o json | jq ".value" | base64 --decode)
else
    SECRET_YAML=$(az keyvault secret show --vault-name $VAULT_NAME --name $SECRET_NAME -o json | jq ".value" | base64 -id)
fi

if [ -f "/tmp/$NAME.yaml" ]; then
    rm "/tmp/$NAME.yaml"
fi
echo -e "$SECRET_YAML" | sed -e 's/^"//' -e 's/"$//' > "/tmp/$NAME.yaml"

NAMESPACE_ARRAY=($(echo "$NAMESPACES" | tr ',' '\n'))
for ns in "${NAMESPACE_ARRAY[@]}"
do
    if ! kubectl describe namespace $ns > /dev/null 2>&1; then
        if ! kubectl create namespace $ns; then
            echo "ERROR: failed to create kubernetes namespace $ns"
            exit 1
        fi
    fi

    echo "creating secret '$NAME' on namespace '$ns'"
    kubectl apply -n $ns -f "/tmp/$NAME.yaml" --v=5
done
