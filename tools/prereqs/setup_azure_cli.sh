#!/bin/bash
  
# verify we are running as root
if [[ "$EUID" != 0 ]]; then
    echo "Script must be run as root or sudo."
    exit 1
fi

# prompt for confirmation
echo "This script will install the latest version of the Azure CLI using the Microsoft APT repo."
read -p "Do you wish to continue? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# install base set of tools
sudo apt-get update
sudo apt-get install -y curl apt-transport-https lsb-release gnupg

# install microsoft apt repo key
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

# configure azure cli repo
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

# install azure cli
sudo apt-get update
sudo apt-get install -y azure-cli
