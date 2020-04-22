#!/bin/bash
#set -x
# create a temporary directory that is cleaned up after exection
TMP_DIR=$(mktemp -d -t flux.XXXXXXXXXX) || { echo "Failed to create temp directory"; exit 1; }
function finish {
  rm -rf "$TMP_DIR"
}
trap finish EXIT
cd $TMP_DIR

# are we running on macOs
IS_MACOS=0
HELM_ARCH="linux-amd64"
uname -a | grep Darwin > /dev/null
if [ "$?" -eq "0" ]; then
  IS_MACOS=1
  HELM_ARCH="darwin-amd64"
fi

fetch_helm () {
  # grab helm.
  # set HELM_TAG to a specific version, if needed
  HELM_TAG="v3.1.2"
  if [ -z "$HELM_TAG" ]; then
    if [ "$IS_MACOS" -eq "1" ]; then
      # use sed compatible with MacOS
      HELM_TAG=$(curl -s https://github.com/helm/helm/releases/latest | sed -E 's/.*tag\/(v[1-9\.]+)\".*/\1/')
    else
      HELM_TAG=`curl -s https://github.com/helm/helm/releases/latest | sed -r 's/.*tag\/(v[1-9\.]+)\".*/\1/'`
    fi
    if [ "$?" -ne "0" ]; then
      echo "Failed to retrieve helm version"
      exit 1
    fi
  fi

  # fetch helm
  curl -L -s --output helm.tgz https://get.helm.sh/helm-$HELM_TAG-$HELM_ARCH.tar.gz
  if [ "$?" -ne "0" ]; then
    echo "unable to retrieve helm"
    exit 1
  fi

  # expand helm
  tar -xf helm.tgz
  if [ "$?" -ne "0" ]; then
    echo "unable to extract helm"
    exit 1
  fi

  cd -
}

while getopts :b:f:g:k:d:e:c:l:s:r:t:z: option
do
 case "${option}" in
 b) GITOPS_URL_BRANCH=${OPTARG};;
 f) FLUX_REPO_URL=${OPTARG};;
 g) GITOPS_SSH_URL=${OPTARG};;
 k) GITOPS_SSH_KEY=${OPTARG};;
 d) REPO_ROOT_DIR=${OPTARG};;
 e) GITOPS_PATH=${OPTARG};;
 c) GITOPS_POLL_INTERVAL=${OPTARG};;
 l) GITOPS_LABEL=${OPTARG};;
 s) ACR_ENABLED=${OPTARG};;
 r) FLUX_IMAGE_REPOSITORY=${OPTARG};;
 t) FLUX_IMAGE_TAG=${OPTARG};;
 z) GC_ENABLED=${OPTARG};;
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

# fetch helm
fetch_helm

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
HELM_BIN="$TMP_DIR/$HELM_ARCH/helm"
echo "generating flux manifests with helm template"
if ! $HELM_BIN template $RELEASE_NAME . \
        --values values.yaml \
        --namespace "$KUBE_NAMESPACE" \
        --set image.repository="$FLUX_IMAGE_REPOSITORY" \
        --set image.tag="$FLUX_IMAGE_TAG" \
        --output-dir "./$FLUX_MANIFESTS" \
        --set git.url="$GITOPS_SSH_URL" \
        --set git.branch="$GITOPS_URL_BRANCH" \
        --set git.secretName="$KUBE_SECRET_NAME" \
        --set git.path="$GITOPS_PATH" \
        --set git.pollInterval="$GITOPS_POLL_INTERVAL" \
        --set git.label="$GITOPS_LABEL" \
        --set registry.acr.enabled="$ACR_ENABLED" \
        --set syncGarbageCollection.enabled="$GC_ENABLED"; then
        --set serviceAccount.name="flux"
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

    secret=$(< "$GITOPS_SSH_KEY" base64 -w 0)
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
