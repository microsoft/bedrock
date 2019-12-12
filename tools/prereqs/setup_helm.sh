#!/bin/bash

HELM_DESIRED_VERSION="v2.16.1"

# load common functions
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
. $SCRIPT_DIR/common_funcs.sh

require_root

function finish {
    if [ ! -z "$tmp_dir" ]; then
        rm -rf $tmp_dir
    fi
}
trap finish EXIT

# prompt for confirmation
echo "This script will install version $HELM_DESIRED_VERSION of helm from Github."
echo "Bedrock currently only supports version 2.x of helm."
read -p "Do you wish to continue? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# create a temporary directory to do work in
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
cd $tmp_dir

# retrieve and install helm
# Currently, Bedrock only works with Helm 2.x, so specifying a specific version
curl -LO https://git.io/get_helm.sh
chmod 700 ./get_helm.sh
./get_helm.sh --version $HELM_DESIRED_VERSION
cd -

echo "heml installed into /usr/local/bin"