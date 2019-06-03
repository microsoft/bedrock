#!/bin/sh
while getopts :b:f:g:k:d:e:c:s:r:t: option
do
 case "${option}" in
 b) GITOPS_URL_BRANCH=${OPTARG};;
 f) FLUX_REPO_URL=${OPTARG};;
 g) GITOPS_SSH_URL=${OPTARG};;
 k) GITOPS_SSH_KEY=${OPTARG};;
 d) REPO_ROOT_DIR=${OPTARG};;
 e) GITOPS_PATH=${OPTARG};;
 c) GITOPS_POLL_INTERVAL=${OPTARG};;
 s) ACR_ENABLED=${OPTARG};;
 r) FLUX_IMAGE_REPOSITORY=${OPTARG};;
 t) FLUX_IMAGE_TAG=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

KUBE_SECRET_NAME="flux-ssh"
RELEASE_NAME="flux"
KUBE_NAMESPACE="flux"
CLONE_DIR="flux"
REPO_DIR="$REPO_ROOT_DIR/$CLONE_DIR"
FLUX_CHART_DIR="chart/flux"
FLUX_MANIFESTS="manifests"

echo "flux repo root directory: $REPO_ROOT_DIR"

rm -rf "$REPO_ROOT_DIR"

echo "creating $REPO_ROOT_DIR directory"
if ! mkdir "$REPO_ROOT_DIR"; then
    echo "ERROR: failed to create directory $REPO_ROOT_DIR"
    exit 1
fi

cd "$REPO_ROOT_DIR" || exit 1

echo "cloning $FLUX_REPO_URL"

if ! git clone -b "$FLUX_IMAGE_TAG" "$FLUX_REPO_URL"; then
    echo "ERROR: failed to clone $FLUX_REPO_URL"
    exit 1
fi

cd "$CLONE_DIR/$FLUX_CHART_DIR" || exit 1

echo "creating $FLUX_MANIFESTS directory"
if ! mkdir "$FLUX_MANIFESTS"; then
    echo "ERROR: failed to create directory $FLUX_MANIFESTS"
    exit 1
fi

# call helm template with
#   release name: flux
#   git url: where flux monitors for manifests
#   git ssh secret: kubernetes secret object for flux to read/write access to manifests repo
echo "generating flux manifests with helm template"
if ! helm template . --name "$RELEASE_NAME" --namespace "$KUBE_NAMESPACE" --values values.yaml --set image.repository="$FLUX_IMAGE_REPOSITORY" --set image.tag="$FLUX_IMAGE_TAG" --output-dir "./$FLUX_MANIFESTS" --set git.url="$GITOPS_SSH_URL" --set git.branch="$GITOPS_URL_BRANCH" --set git.secretName="$KUBE_SECRET_NAME" --set git.path="$GITOPS_PATH" --set git.pollInterval="$GITOPS_POLL_INTERVAL" --set registry.acr.enabled="$ACR_ENABLED"; then
    echo "ERROR: failed to helm template"
    exit 1
fi

# back to the root dir
cd ../../../../ || exit 1


echo "creating kubernetes namespace $KUBE_NAMESPACE if needed"
if ! kubectl describe namespace $KUBE_NAMESPACE > /dev/null 2>&1; then
    if ! kubectl create namespace $KUBE_NAMESPACE; then
        echo "ERROR: failed to create kubernetes namespace $KUBE_NAMESPACE"
        exit 1
    fi
fi

echo "creating kubernetes secret $KUBE_SECRET_NAME from key file path $GITOPS_SSH_KEY"

if kubectl get secret $KUBE_SECRET_NAME -n $KUBE_NAMESPACE > /dev/null 2>&1; then
    # kubectl doesn't provide a native way to patch a secret using --from-file.
    # The update path requires loading the secret, base64 encoding it, and then
    # making a call to the 'kubectl patch secret' command.
    if [ ! -f "$GITOPS_SSH_KEY" ]; then
        echo "ERROR: unable to load GITOPS_SSH_KEY: $GITOPS_SSH_KEY"
        exit 1
    fi

    secret=$(< "$GITOPS_SSH_KEY" base64)
    if ! kubectl patch secret $KUBE_SECRET_NAME -n $KUBE_NAMESPACE -p="{\"data\":{\"identity\": \"$secret\"}}"; then
        echo "ERROR: failed to patch existing flux secret: $KUBE_SECRET_NAME "
        exit 1
    fi
else
    if ! kubectl create secret generic $KUBE_SECRET_NAME --from-file=identity="$GITOPS_SSH_KEY" -n $KUBE_NAMESPACE; then
        echo "ERROR: failed to create secret: $KUBE_SECRET_NAME"
        exit 1
    fi
fi

echo "Applying flux deployment"
if ! kubectl apply -f  "$REPO_DIR/$FLUX_CHART_DIR/$FLUX_MANIFESTS/flux/templates" -n $KUBE_NAMESPACE; then
    echo "ERROR: failed to apply flux deployment"
    exit 1
fi
