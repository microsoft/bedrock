#!/bin/sh
while getopts :o:c:r: option
do
 case "${option}" in
 o) OWNERS=${OPTARG};;
 c) CONTRIBUTORS=${OPTARG};;
 r) READERS=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ -z $OWNERS ]; then
    echo "OWNERS is empty"
else
    OWNERs_YAML="---"
    OWNERs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    OWNERs_YAML+="\nkind: ClusterRoleBinding"
    OWNERs_YAML+="\nmetadata:"
    OWNERs_YAML+="\n  name: aks-cluster-admins"
    OWNERs_YAML+="\nroleRef:"
    OWNERs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    OWNERs_YAML+="\n  kind: ClusterRole"
    OWNERs_YAML+="\n  name: cluster-admin"
    OWNERs_YAML+="\nsubjects:"

    OWNERS_ARRAY=($(echo "$OWNERS" | tr ',' '\n'))
    for i in "${OWNERS_ARRAY[@]}"
    do
        OWNERs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        OWNERs_YAML+="\n    kind: User"
        OWNERs_YAML+="\n    name: $i"
    done

    echo "owners yaml file:"
    echo "$OWNERs_YAML"
    echo "\napplying...\n"

    echo "$OWNERs_YAML" | kubectl apply -f -

    echo "\ndone!"
fi


if [ -z $CONTRIBUTORS ]; then
    echo "CONTRIBUTORS is empty"
else
    CONTRIBUTORs_YAML="---"
    CONTRIBUTORs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    CONTRIBUTORs_YAML+="\nkind: ClusterRoleBinding"
    CONTRIBUTORs_YAML+="\nmetadata:"
    CONTRIBUTORs_YAML+="\n  name: aks-cluster-admins"
    CONTRIBUTORs_YAML+="\nroleRef:"
    CONTRIBUTORs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    CONTRIBUTORs_YAML+="\n  kind: ClusterRole"
    CONTRIBUTORs_YAML+="\n  name: cluster-admin"
    CONTRIBUTORs_YAML+="\nsubjects:"

    CONTRIBUTORS_ARRAY=($(echo "$CONTRIBUTORS" | tr ',' '\n'))
    for i in "${CONTRIBUTORS_ARRAY[@]}"
    do
        CONTRIBUTORs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        CONTRIBUTORs_YAML+="\n    kind: User"
        CONTRIBUTORs_YAML+="\n    name: $i"
    done

    echo "owners yaml file:"
    echo "$CONTRIBUTORs_YAML"
    echo "\napplying...\n"

    echo "$CONTRIBUTORs_YAML" | kubectl apply -f -

    echo "\ndone!"
fi


if [ -z $READERS ]; then
    echo "READERS is empty"
else
    READERs_YAML="---"
    READERs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    READERs_YAML+="\nkind: ClusterRoleBinding"
    READERs_YAML+="\nmetadata:"
    READERs_YAML+="\n  name: aks-cluster-admins"
    READERs_YAML+="\nroleRef:"
    READERs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    READERs_YAML+="\n  kind: ClusterRole"
    READERs_YAML+="\n  name: cluster-admin"
    READERs_YAML+="\nsubjects:"

    READERS_ARRAY=($(echo "$READERS" | tr ',' '\n'))
    for i in "${READERS_ARRAY[@]}"
    do
        READERs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        READERs_YAML+="\n    kind: User"
        READERs_YAML+="\n    name: $i"
    done

    echo "owners yaml file:"
    echo "$READERs_YAML"
    echo "\napplying...\n"

    echo "$READERs_YAML" | kubectl apply -f -

    echo "\ndone!"
fi
