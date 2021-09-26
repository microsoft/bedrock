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
echo "This script will install the latest version of Fabrikate from github."
echo "The script requires that unzip be installed."
# next 6 lines commented due to automation
#read -p "Do you wish to continue? " -n 1 -r
#echo
#if [[ ! $REPLY =~ ^[Yy]$ ]]
#then
#    exit 1
#fi

# determine os type
ostype=`os_type`
if [ "$ostype" == "linux" ]; then
    arch="linux-amd64"
    apt-get install -y unzip
elif [ "$ostype" == "macos" ]; then
    arch="darwin-amd64"
else
    echo "OS ($ostype) not supported."
    exit 1
fi

# create a temporary directory to do work in
tmp_dir=$(mktemp -d -t fab-inst-XXXXXXXXXX)
cd $tmp_dir

FABRIKATE_FILE=`curl -s -L https://github.com/microsoft/fabrikate/releases/latest | grep "$arch" | sed -n "s/.*\(fab-v[0-9]*.[0-9]*.[0-9]*-$arch.zip\).*/\1/p" | sort -u`

FABRIKATE_VERSION=`echo $FABRIKATE_FILE | sed -n 's/.*v\([0-9]*.[0-9]*.[0-9]*\).*/\1/p'`

curl -s -LO https://github.com/microsoft/fabrikate/releases/download/$FABRIKATE_VERSION/$FABRIKATE_FILE
unzip $FABRIKATE_FILE -d /usr/local/bin

cd -

echo "fab installed into /usr/local/bin"