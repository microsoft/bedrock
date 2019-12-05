#!/bin/bash
  
# verify we are running as root
if [[ "$EUID" != 0 ]]; then
    echo "Script must be run as root or sudo."
    exit 1
fi

# prompt for confirmation
echo "This script will install the latest version of Terraform from github."
read -p "Do you wish to continue? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# create a temporary directory to do work in
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
cd $tmp_dir

TERRAFORM_VERSION=`curl -L -s https://github.com/hashicorp/terraform/releases/latest | grep archive | grep zip | sed -n 's/.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p' | sed 's/v//g'`
curl -LO -s https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_"$TERRAFORM_VERSION"_linux_amd64.zip

unzip terraform_"$TERRAFORM_VERSION"_linux_amd64.zip -d /usr/local/bin/

cd ..
rm -rf $tmp_dir
