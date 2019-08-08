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

if [ ${#OWNERS[@]} > 0 ]; then
    $OWNER_YAML_FILE = "$OUTPUT_FOLDER/owners.yaml"
    "apiVersion: rbac.authorization.k8s.io/v1" >> $OWNER_YAML_FILE
    "kind: ClusterRoleBinding" >> $OWNER_YAML_FILE
    "metadata:" >> $OWNER_YAML_FILE
    "  name: aks-cluster-admins" >> $OWNER_YAML_FILE
    "roleRef:" >> $OWNER_YAML_FILE
    "  apiGroup: rbac.authorization.k8s.io" >> $OWNER_YAML_FILE
    "  kind: ClusterRole" >> $OWNER_YAML_FILE
    "  name: cluster-admin" >> $OWNER_YAML_FILE
    "subjects:" >> $OWNER_YAML_FILE
    `
    for i in "${OWNERS[@]}"
    do
        "  - apiGroup: rbac.authorization.k8s.io" >> $OWNER_YAML_FILE
        "    kind: User" >> $OWNER_YAML_FILE
        "    name: $i" >> $OWNER_YAML_FILE
    done
    ;
    kubectl apply -f $OWNER_YAML_FILE
fi
