#!/bin/sh
while getopts :o:c:r:f: option
do
 case "${option}" in
 o) OWNERS=${OPTARG};;
 c) CONTRIBUTORS=${OPTARG};;
 r) READERS=${OPTARG};;
 f) OUTPUT_FOLDER=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ ${#OWNERS[@]} -eq 0 ]; then
    echo "OWNERS is empty"
else
    OWNER_YAML_FILE="$OUTPUT_FOLDER/owners.yaml"
    echo "Generating yaml file for owners: $OWNER_YAML_FILE"
    rm -f $OWNER_YAML_FILE
    echo "apiVersion: rbac.authorization.k8s.io/v1" >> $OWNER_YAML_FILE
    echo "kind: ClusterRoleBinding" >> $OWNER_YAML_FILE
    echo "metadata:" >> $OWNER_YAML_FILE
    echo "  name: aks-cluster-admins" >> $OWNER_YAML_FILE
    echo "roleRef:" >> $OWNER_YAML_FILE
    echo "  apiGroup: rbac.authorization.k8s.io" >> $OWNER_YAML_FILE
    echo "  kind: ClusterRole" >> $OWNER_YAML_FILE
    echo "  name: cluster-admin" >> $OWNER_YAML_FILE
    echo "subjects:" >> $OWNER_YAML_FILE

    for i in "${OWNERS[@]}"
    do
        echo "  - apiGroup: rbac.authorization.k8s.io" >> $OWNER_YAML_FILE
        echo "    kind: User" >> $OWNER_YAML_FILE
        echo "    name: $i" >> $OWNER_YAML_FILE
    done

    kubectl apply -f $OWNER_YAML_FILE;
fi
