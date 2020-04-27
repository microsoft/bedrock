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
echo "This script will install the latest version of Bedrock CLI from github."
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

BEDROCK_CLI_VERSION=$(curl -s "https://api.github.com/repos/microsoft/bedrock-cli/releases/latest" | grep "tag_name" | sed -E 's/.*"([^"]+)".*/\1/')

curl -s -LO https://github.com/microsoft/bedrock-cli/releases/download/$BEDROCK_CLI_VERSION/bedrock-$arch
cp bedrock-$arch /usr/local/bin/bedrock
chmod +x /usr/local/bin/bedrock

echo "bedrock installed into /usr/local/bin"