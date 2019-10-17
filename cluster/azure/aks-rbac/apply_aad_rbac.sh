#!/bin/bash
while getopts :o:c:r:n:d:s:a:b: option
do
    case "${option}" in
        o) OWNERS=${OPTARG};;
        c) CONTRIBUTORS=${OPTARG};;
        r) READERS=${OPTARG};;
        n) OWNERGROUPS=${OPTARG};;
        d) CONTRIBUTORGROUPS=${OPTARG};;
        s) READERGROUPS=${OPTARG};;
        a) CONTRIBUTOR_CLUSTER_ROLE_FILE=${OPTARG};;
        b) READER_CLUSTER_ROLE_FILE=${OPTARG};;
        *) echo "Please refer to usage guide on GitHub" >&2
            exit 1 ;;
    esac
done

if ! kubectl apply -f "$CONTRIBUTOR_CLUSTER_ROLE_FILE"
then
    echo "Unable to deploy cluster role cluster-contributor."
    exit 1
fi

if ! kubectl apply -f "$READER_CLUSTER_ROLE_FILE"
then
    echo "Unable to deploy cluster role: cluster-reader."
    exit 1
fi

if [ -z $OWNERS ] || [ "$OWNERS"=="empty" ]; then
    echo "OWNERS is empty"
else
    echo "OWNERS: $OWNERS"

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
    echo -e "$OWNERs_YAML"
    echo "\napplying...\n"

    echo -e "$OWNERs_YAML" | kubectl apply -f -

    echo -e "\ndone!"
fi

if [ -z $CONTRIBUTORS ] || [ "$CONTRIBUTORS"=="empty" ]; then
    echo "CONTRIBUTORS is empty"
else
    echo "CONTRIBUTORS: $CONTRIBUTORS"

    CONTRIBUTORs_YAML="---"
    CONTRIBUTORs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    CONTRIBUTORs_YAML+="\nkind: ClusterRoleBinding"
    CONTRIBUTORs_YAML+="\nmetadata:"
    CONTRIBUTORs_YAML+="\n  name: aks-cluster-contributors"
    CONTRIBUTORs_YAML+="\nroleRef:"
    CONTRIBUTORs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    CONTRIBUTORs_YAML+="\n  kind: ClusterRole"
    CONTRIBUTORs_YAML+="\n  name: cluster-contributor"
    CONTRIBUTORs_YAML+="\nsubjects:"

    CONTRIBUTORS_ARRAY=($(echo "$CONTRIBUTORS" | tr ',' '\n'))
    for c in "${CONTRIBUTORS_ARRAY[@]}"
    do
        CONTRIBUTORs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        CONTRIBUTORs_YAML+="\n    kind: User"
        CONTRIBUTORs_YAML+="\n    name: $c"
    done


    echo "owners yaml file:"
    echo -e "$CONTRIBUTORs_YAML"
    echo "\napplying...\n"

    echo -e "$CONTRIBUTORs_YAML" | kubectl apply -f -

    echo -e "\ndone!"
fi


if [ -z $READERS ] || [ "$READERS"=="empty" ]; then
    echo "READERS is empty"
else
    echo "READERS: $READERS"

    READERs_YAML="---"
    READERs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    READERs_YAML+="\nkind: ClusterRoleBinding"
    READERs_YAML+="\nmetadata:"
    READERs_YAML+="\n  name: aks-cluster-readers"
    READERs_YAML+="\nroleRef:"
    READERs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    READERs_YAML+="\n  kind: ClusterRole"
    READERs_YAML+="\n  name: cluster-reader"
    READERs_YAML+="\nsubjects:"

    READERS_ARRAY=($(echo "$READERS" | tr ',' '\n'))
    for r in "${READERS_ARRAY[@]}"
    do
        READERs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        READERs_YAML+="\n    kind: User"
        READERs_YAML+="\n    name: $r"
    done

    echo "owners yaml file:"
    echo -e "$READERs_YAML"
    echo "\napplying...\n"

    echo -e "$READERs_YAML" | kubectl apply -f -

    echo -e "\ndone!"
fi

if [ -z $OWNERGROUPS ] || [ "$OWNERGROUPS"=="empty" ]; then
    echo "OWNERGROUPS is empty"
else
    echo "OWNERGROUPS: $OWNERGROUPS"

    OWNERGROUPs_YAML="---"
    OWNERGROUPs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    OWNERGROUPs_YAML+="\nkind: ClusterRoleBinding"
    OWNERGROUPs_YAML+="\nmetadata:"
    OWNERGROUPs_YAML+="\n  name: aks-cluster-admin-groups"
    OWNERGROUPs_YAML+="\nroleRef:"
    OWNERGROUPs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    OWNERGROUPs_YAML+="\n  kind: ClusterRole"
    OWNERGROUPs_YAML+="\n  name: cluster-admin"
    OWNERGROUPs_YAML+="\nsubjects:"

    OWNERGROUPS_ARRAY=($(echo "$OWNERGROUPS" | tr ',' '\n'))
    for i in "${OWNERGROUPS_ARRAY[@]}"
    do
        OWNERGROUPs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        OWNERGROUPs_YAML+="\n    kind: Group"
        OWNERGROUPs_YAML+="\n    name: $i"
    done

    echo "owners yaml file:"
    echo -e "$OWNERGROUPs_YAML"
    echo "\napplying...\n"

    echo -e "$OWNERGROUPs_YAML" | kubectl apply -f -

    echo -e "\ndone!"
fi

if [ -z $CONTRIBUTORGROUPS ] || [ "$CONTRIBUTORGROUPS"=="empty" ]; then
    echo "CONTRIBUTORGROUPS is empty"
else
    echo "CONTRIBUTORGROUPS: $CONTRIBUTORGROUPS"

    CONTRIBUTORGROUPs_YAML="---"
    CONTRIBUTORGROUPs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    CONTRIBUTORGROUPs_YAML+="\nkind: ClusterRoleBinding"
    CONTRIBUTORGROUPs_YAML+="\nmetadata:"
    CONTRIBUTORGROUPs_YAML+="\n  name: aks-cluster-contributor-groups"
    CONTRIBUTORGROUPs_YAML+="\nroleRef:"
    CONTRIBUTORGROUPs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    CONTRIBUTORGROUPs_YAML+="\n  kind: ClusterRole"
    CONTRIBUTORGROUPs_YAML+="\n  name: cluster-contributor"
    CONTRIBUTORGROUPs_YAML+="\nsubjects:"

    CONTRIBUTORGROUPS_ARRAY=($(echo "$CONTRIBUTORGROUPS" | tr ',' '\n'))
    for c in "${CONTRIBUTORGROUPS_ARRAY[@]}"
    do
        CONTRIBUTORGROUPs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        CONTRIBUTORGROUPs_YAML+="\n    kind: Group"
        CONTRIBUTORGROUPs_YAML+="\n    name: $c"
    done


    echo "contributors yaml file:"
    echo -e "$CONTRIBUTORGROUPs_YAML"
    echo "\napplying...\n"

    echo -e "$CONTRIBUTORGROUPs_YAML" | kubectl apply -f -

    echo -e "\ndone!"
fi


if [ -z $READERGROUPS ] || [ "$READERGROUPS"=="empty" ]; then
    echo "READERGROUPS is empty"
else
    echo "READERGROUPS: $READERGROUPS"

    READERGROUPs_YAML="---"
    READERGROUPs_YAML+="\napiVersion: rbac.authorization.k8s.io/v1"
    READERGROUPs_YAML+="\nkind: ClusterRoleBinding"
    READERGROUPs_YAML+="\nmetadata:"
    READERGROUPs_YAML+="\n  name: aks-cluster-reader-groups"
    READERGROUPs_YAML+="\nroleRef:"
    READERGROUPs_YAML+="\n  apiGroup: rbac.authorization.k8s.io"
    READERGROUPs_YAML+="\n  kind: ClusterRole"
    READERGROUPs_YAML+="\n  name: cluster-reader"
    READERGROUPs_YAML+="\nsubjects:"

    READERGROUPS_ARRAY=($(echo "$READERGROUPS" | tr ',' '\n'))
    for r in "${READERGROUPS_ARRAY[@]}"
    do
        READERGROUPs_YAML+="\n  - apiGroup: rbac.authorization.k8s.io"
        READERGROUPs_YAML+="\n    kind: Group"
        READERGROUPs_YAML+="\n    name: $r"
    done

    echo "readers yaml file:"
    echo -e "$READERGROUPs_YAML"
    echo "\napplying...\n"

    echo -e "$READERGROUPs_YAML" | kubectl apply -f -

    echo -e "\ndone!"
fi
