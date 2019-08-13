#!/bin/bash

KUBE_NAMESPACE="load-test"
LOCUST_TASKS_CONFIG_NAME="locust-tasks-config"

while getopts :w:h:c:r:t:s:n:k:p: option
do
case "${option}" in
    w) WORKER_COUNT=${OPTARG};;
    h) TARGET_HOST=${OPTARG};;
    c) LOCUST_TASKS_CONFIG_NAME=${OPTARG};;
    r) LOCUST_IMAGE_REPOSITORY=${OPTARG};;
    t) LOCUST_IMAGE_TAG=${OPTARG};;
    s) LOCUST_IMAGE_REPOSITORY_SECRET=${OPTARG};;
    n) KUBE_NAMESPACE=${OPTARG};;
    k) API_AUTH_KEY=${OPTARG};;
    p) API_AUTH_SECRET=${OPTARG};;
    *) echo "Please refer to usage guide on GitHub" >&2
        exit 1 ;;
esac
done

locust_chart="stable/locust"
chart_dir="locust"
manifests_dir="manifests"
release_name="locust"
locust_tasks_file="locust-tasks"
api_auth_key_name="API_AUTH_KEY"
api_auth_secret_name="API_AUTH_SECRET"

echo "creating kubernetes namespace $KUBE_NAMESPACE if needed"
if ! kubectl describe namespace $KUBE_NAMESPACE > /dev/null 2>&1; then
    if ! kubectl create namespace $KUBE_NAMESPACE; then
        echo "ERROR: failed to create kubernetes namespace $KUBE_NAMESPACE"
        exit 1
    fi
fi

echo "creating kubernetes config map $LOCUST_TASKS_CONFIG_NAME in namespace $KUBE_NAMESPACE if needed"
if ! kubectl describe configmap $LOCUST_TASKS_CONFIG_NAME > /dev/null 2>&1; then
    if ! kubectl create configmap $LOCUST_TASKS_CONFIG_NAME --from-file="$locust_tasks_file" -n $KUBE_NAMESPACE; then
        echo "ERROR: failed to create kubernetes configmap $LOCUST_TASKS_CONFIG_NAME"
        exit 1
    fi
fi

rm -rf "$chart_dir"

echo "fetching locust helm chart $locust_chart"

if ! helm fetch $locust_chart --untar --untardir $chart_dir; then
    echo "ERROR: failed to clone $FLUX_REPO_URL"
    exit 1
fi

cd $chart_dir/locust

echo "creating $manifests_dir directory"
if ! mkdir "$manifests_dir"; then
    echo "ERROR: failed to create directory $manifests_dir"
    exit 1
fi

helm_options="--name=\"$release_name\" --namespace=\"$KUBE_NAMESPACE\" --values values.yaml --set image.repository=\"$LOCUST_IMAGE_REPOSITORY\" --set image.tag=\"$LOCUST_IMAGE_TAG\" --set worker.config.configmapName=\"$LOCUST_TASKS_CONFIG_NAME\" --set service.type=\"LoadBalancer\" --set master.config.target-host=\"$TARGET_HOST\" --set worker.replicaCount=\"$WORKER_COUNT\" --output-dir \"./$manifests_dir\""

if [ ! -z "$LOCUST_IMAGE_REPOSITORY_SECRET" ]; then 
    helm_options="$helm_options --set image.pullSecrets[0].name=\"$LOCUST_IMAGE_REPOSITORY_SECRET\""
fi

if [ ! -z "$API_AUTH_KEY" ] && [ ! -z "$API_AUTH_SECRET" ]; then
    helm_options="$helm_options --set extraEnvs[0].name=\"$api_auth_key_name\" --set extraEnvs[0].value=\"$API_AUTH_KEY\" --set extraEnvs[1].name=\"$api_auth_secret_name\" --set extraEnvs[1].value=\"$API_AUTH_SECRET\""
fi

if [ ! -z "$LOCUST_IMAGE_REPOSITORY_SECRET" ]; then 
    helm_options="$helm_options --set image.pullSecrets[0].name=\"$LOCUST_IMAGE_REPOSITORY_SECRET\""
fi

echo $helm_options

echo "generating locust manifests with helm template"
if ! eval helm template . "$helm_options" ; then
    echo "ERROR: failed to helm template"
    exit 1
fi

# back to the root dir (loadtest)
cd ../../ || exit 1

echo "applying locust deployment"
if ! kubectl apply -f  "$chart_dir/locust/$manifests_dir/locust/templates" -n $KUBE_NAMESPACE; then
    echo "ERROR: failed to apply locust deployment"
    exit 1
fi