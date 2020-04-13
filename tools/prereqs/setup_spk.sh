#!/bin/bash
set -e
  
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
echo "This script will install the latest version of Spk from github."
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
    arch="linux"
elif [ "$ostype" == "macos" ]; then
    arch="macos"
else
    echo "OS ($ostype) not supported."
    exit 1
fi

SPK_VERSION=`curl -s -L https://github.com/microsoft/bedrock-cli/releases/latest | grep "spk\/archive" | grep zip | awk -F"archive/" '{print $2}' | awk -F ".zip" '{print $1}'`

curl -s -LO https://github.com/microsoft/bedrock-cli/releases/download/$SPK_VERSION/spk-$arch
cp spk-$arch /usr/local/bin/spk
chmod +x /usr/local/bin/spk

echo "spk installed into /usr/local/bin"