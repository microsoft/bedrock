#!/bin/bash

# load common functions
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
. $SCRIPT_DIR/common_funcs.sh

require_root

function apt_install() {
    # prompt for confirmation
    echo "This script will install the latest version of the Azure CLI using the Microsoft APT repo."
    # next 6 lines commented due to automation
    #read -p "Do you wish to continue? " -n 1 -r
    #echo
    #if [[ ! $REPLY =~ ^[Yy]$ ]]
    #then
    #    exit 1
    #fi

    # install base set of tools
    apt-get update
    apt-get install -y curl apt-transport-https lsb-release gnupg

    # install microsoft apt repo key
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
        tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

    # configure azure cli repo
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
        tee /etc/apt/sources.list.d/azure-cli.list

    # install azure cli
    apt-get update
    apt-get install -y azure-cli
}

function manual_install() {
    # prompt for confirmation
    echo "This script will install the latest version of the Azure CLI using the"
    echo "manual install method which launches a script.  The script will prompt"
    echo "for a few questions, like where to install the Azure CLI."
    read -p "Do you wish to continue? " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi

    which curl
    if [ "$?" != "0" ]; then
        echo "curl is required to install the script."
        exit 1
    fi

    curl -L https://aka.ms/InstallAzureCli | bash
}

function macos_brew_install() {
    # prompt for confirmation
    echo "This script will install the latest version of the Azure CLI using brew."
    read -p "Do you wish to continue? " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi

    brew update && brew install azure-cli
}

function macos_install() {
    which brew
    if [ "$?" -eq "0" ]; then
        macos_brew_install
    else
        manual_install
    fi
}

# Determine the operating system and call the appropriate
# install method.  If there isn't a specific specialized 
# install, then use the Azure CLI manual install.
ostype=`os_type`
if [ "$ostype" == "linux" ]; then
    `is_apt_system`
    if [ "$?" -eq "1" ]; then
        apt_install
    else
        manual_install
    fi
elif [ "$ostype" == "macos" ]; then
    macos_install
else
    manual_install
fi
