#!/bin/sh
while getopts f:g:k:c option 
do 
 case "${option}" in 
 f) FLUX_REPO_URL=${OPTARG};; 
 g) GITOPS_URL=${OPTARG};; 
 k) GITOPS_SSH_KEY=${OPTARG};; 
 esac
done 

KUBE_SECRET_NAME="flux-ssh"
KUBE_NAMESPACE=flux
REPO_DIR="flux"
FLUX_CHART_DIR="flux/chart/flux"
FLUX_MANIFESTS="manifests"

echo "cloning $FLUX_REPO_URL"
rm -rf $REPO_DIR

if ! git clone $FLUX_REPO_URL; then
    echo "ERROR: failed to clone $FLUX_REPO_URL"
    exit 1
fi

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
if ! helm template . --name flux --values values.yaml --output-dir ./$FLUX_MANIFESTS --set git.url=$GITOPS_URL --set git.secretName=$KUBE_SECRET_NAME; then
    echo "ERROR: failed to helm template"
    exit 1
fi

cd ../../../

echo "creating kubernetes secret $KUBE_SECRET_NAME from key file path $GITOPS_SSH_KEY"
kubectl create secret generic $KUBE_SECRET_NAME --from-file=identity=$GITOPS_SSH_KEY

echo "Applying flux deployment"
if ! kubectl apply -f  $FLUX_CHART_DIR/$FLUX_MANIFESTS/flux/templates; then
    echo "ERROR: failed to apply flux deployment"
    exit 1
fi