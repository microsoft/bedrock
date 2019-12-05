#!/bin/bash
  
# verify we are running as root
if [[ "$EUID" != 0 ]]; then
    echo "Script must be run as root or sudo."
    exit 1
fi

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

# retrieve and install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
mv kubectl /usr/local/bin/
chmod +x /usr/local/bin/kubectl

cd
rm -rf $tmp_dir

