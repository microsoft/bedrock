#!/bin/sh
while getopts f:g:k:d:c option 
do 
 case "${option}" in 
 f) FLUX_REPO_URL=${OPTARG};;
 g) GITOPS_URL=${OPTARG};;
 k) GITOPS_SSH_KEY=${OPTARG};;
 d) REPO_ROOT_DIR=${OPTARG};;
 esac
done 

KUBE_SECRET_NAME="flux-ssh"
RELEASE_NAME="flux"
KUBE_NAMESPACE="flux"
REPO_DIR="$REPO_ROOT_DIR/flux"
FLUX_CHART_DIR="flux/chart/flux"
FLUX_MANIFESTS="manifests"

rm -rf $REPO_ROOT_DIR

echo "creating $REPO_ROOT_DIR directory"
if ! mkdir $REPO_ROOT_DIR; then
    echo "ERROR: failed to create directory $REPO_ROOT_DIR"
    exit 1
fi

cd $REPO_ROOT_DIR

echo "cloning $FLUX_REPO_URL"
rm -rf $REPO_DIR

if ! git clone $FLUX_REPO_URL; then
    echo "ERROR: failed to clone $FLUX_REPO_URL"
    exit 1
fi

echo "flux chart dir is $FLUX_CHART_DIR"
cd $FLUX_CHART_DIR

echo "creating $FLUX_MANIFESTS directory"
if ! mkdir $FLUX_MANIFESTS; then
    echo "ERROR: failed to create directory $FLUX_MANIFESTS"
    exit 1
fi

# call helm template with
#   release name: flux
#   git url: where flux monitors for manifests
#   git ssh secret: kubernetes secret object for flux to read/write access to manifests repo
echo "generating flux manifests with helm template"
if ! helm template . --name $RELEASE_NAME --namespace $KUBE_NAMESPACE --values values.yaml --output-dir ./$FLUX_MANIFESTS --set git.url=$GITOPS_URL --set git.secretName=$KUBE_SECRET_NAME; then
    echo "ERROR: failed to helm template"
    exit 1
fi

# back to the roor dir
cd ../../../../

echo "creating kubernetes namespace $KUBE_NAMESPACE"
if ! kubectl create namespace $KUBE_NAMESPACE; then
    echo "ERROR: failed to create kubernetes namespace $KUBE_NAMESPACE"
    exit 1
fi

echo "creating kubernetes secret $KUBE_SECRET_NAME from key file path $GITOPS_SSH_KEY"
if ! kubectl create secret generic $KUBE_SECRET_NAME --from-file=identity=$GITOPS_SSH_KEY -n $KUBE_NAMESPACE; then
    echo "ERROR: failed to create kubernetes secret $KUBE_SECRET_NAME from key file path $GITOPS_SSH_KEY"
    exit 1
fi

echo "Applying flux deployment"
if ! kubectl apply -f  $REPO_ROOT_DIR/$FLUX_CHART_DIR/$FLUX_MANIFESTS/flux/templates -n $KUBE_NAMESPACE; then
    echo "ERROR: failed to apply flux deployment"
    exit 1
fi