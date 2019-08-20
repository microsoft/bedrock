#!/usr/bin/env bash

while getopts :a:v:n:u:s:p:e: option
do
    case "${option}" in
    a) ACR_NAME=${OPTARG};;
    v) VAULT_NAME=${OPTARG};;
    n) AUTH_SECRET_NAME=${OPTARG};;
    u) USERNAME=${OPTARG};;
    p) PASSWORD=${OPTARG};;
    e) EMAIL=${OPTARG};;
    *) echo "ERROR: Please refer to usage guide on GitHub" >&2
        exit 1 ;;
    esac
done

if [ -z "$ACR_NAME" ]; then
    echo "usage: $0 -v <ACR_NAME>"
    exit 1
fi
if [ -z "$VAULT_NAME" ]; then
    echo "usage: $0 -v <VAULT_NAME>"
    exit 1
fi
if [ -z "$AUTH_SECRET_NAME" ]; then
    echo "usage: $0 -g <AUTH_SECRET_NAME>"
    exit 1
fi
if [ -z "$USERNAME" ]; then
    echo "usage: $0 -g <USERNAME>"
    exit 1
fi
if [ -z "$PASSWORD" ]; then
    echo "usage: $0 -g <PASSWORD>"
    exit 1
fi
if [ -z "$EMAIL" ]; then
    echo "usage: $0 -g <EMAIL>"
    exit 1
fi

AUTH=$(echo "$ACR_NAME:$PASSWORD" | base64)
DOCKERCONFIG="{\"auths\":{\"$ACR_NAME.azurecr.io\":{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"email\":\"$EMAIL\",\"auth\":\"$AUTH\"}}}"

az keyvault secret set --vault-name $VAULT_NAME --name $AUTH_SECRET_NAME --value $DOCKERCONFIG