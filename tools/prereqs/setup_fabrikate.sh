#!/bin/bash
  
# verify we are running as root
if [[ "$EUID" != 0 ]]; then
    echo "Script must be run as root or sudo."
    exit 1
fi

# prompt for confirmation
echo "This script will install the latest version of Fabrikate from github."
echo "The script requires that unzip be installed."
read -p "Do you wish to continue? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# create a temporary directory to do work in
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
cd $tmp_dir

FABRIKATE_FILE=`curl -s -L https://github.com/microsoft/fabrikate/releases/latest | grep "linux-amd64" | sed -n 's/.*\(fab-v[0-9]*.[0-9]*.[0-9]*-linux-amd64.zip\).*/\1/p' | sort -u`

FABRIKATE_VERSION=`echo $FABRIKATE_FILE | sed -n 's/.*v\([0-9]*.[0-9]*.[0-9]*\).*/\1/p'`

curl -s -LO https://github.com/microsoft/fabrikate/releases/download/$FABRIKATE_VERSION/$FABRIKATE_FILE
unzip $FABRIKATE_FILE -d /usr/local/bin

cd -
rm -rf $tmp_dir
