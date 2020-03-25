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
echo "This script will install the latest version of Terraform from github."
read -p "Do you wish to continue? (y or n)" -n 1 -r
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
    arch="linux_amd64"
    sudo apt-get install unzip
elif [ "$ostype" == "macos" ]; then
    arch="darwin_amd64"
    brew install unzip
else
    echo "OS ($ostype) not supported."
    exit 1
fi

TERRAFORM_VERSION=`curl -L -s https://github.com/hashicorp/terraform/releases/latest | grep archive | grep zip | awk -F"/v" '{print $2}' | awk -F".zip" '{print $1}'`
curl -LO -s https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_"$TERRAFORM_VERSION"_$arch.zip

unzip terraform_"$TERRAFORM_VERSION"_$arch.zip -d /usr/local/bin/

echo "terraform installed in /usr/local/bin"