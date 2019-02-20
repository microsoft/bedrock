#!/bin/sh
while getopts :f:g: option
do
 case "${option}" in
 f) KUBEDIFF_REPO_URL=${OPTARG};;
 g) GITOPS_URL=${OPTARG};; 
 esac
done
 
KUBEDIFF_NAMESPACE="kubediff"
REPO_DIR="kubediff"
 
echo "Cloning Kubediff $KUBEDIFF_REPO_URL"
if ! git clone $KUBEDIFF_REPO_URL $REPO_DIR; then
    echo "ERROR: failed to clone $KUBEDIFF_REPO_URL"
    exit 1
fi
 
echo "Cloned kubediff. cd"
cd $REPO_DIR/k8s

if ! sed -i -e 's/<your config repo>/$GITOPS_URL/g' ./kubediff-rc.yaml; then
    echo "ERROR: failed to update with gitops url $GITOPS_URL"
    exit 1
fi
sed '23q;d' ./kubediff-rc.yaml
echo "Updated with gitops url $GITOPS_URL"

echo "creating kubernetes namespace $KUBEDIFF_NAMESPACE"
if ! kubectl create namespace $KUBEDIFF_NAMESPACE; then
    echo "ERROR: failed to create kubernetes namespace $KUBEDIFF_NAMESPACE"
    exit 1
fi

cd ../../

echo "Applying kubediff deployment"
if ! kubectl create -f  $REPO_DIR/k8s/ -n $KUBEDIFF_NAMESPACE; then
    echo "ERROR: failed to apply kubediff deployment"
    exit 1
fi
 
echo "kubediff deployment complete"
