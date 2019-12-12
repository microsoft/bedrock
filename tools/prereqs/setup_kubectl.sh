#!/bin/bash
  
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
echo "This script will install the latest version of kubectl."
read -p "Do you wish to continue? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# create a temporary directory to do work in
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
cd $tmp_dir

# determine os type
ostype=`os_type`
if [ "$ostype" == "linux" ]; then
    arch="linux/amd64"
elif [ "$ostype" == "macos" ]; then
    arch="darwin/amd64"
else
    echo "OS ($ostype) not supported."
    exit 1
fi

# retrieve and install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/$arch/kubectl
mv kubectl /usr/local/bin/
chmod +x /usr/local/bin/kubectl

echo "kubectl installed into /usr/local/bin"