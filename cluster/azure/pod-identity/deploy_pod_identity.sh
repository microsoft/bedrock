#!/bin/sh

# parse command-line arguments
while getopts :u: option 
do 
 case "${option}" in 
 u) POD_IDENTITY_DEPLOYMENT_URL=${OPTARG};;
 *) echo "ERROR: Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done 

# Deploy the flex volume support into the cluster
if ! kubectl create -f "$POD_IDENTITY_DEPLOYMENT_URL"
then
    echo "Unable to deploy flex volume support to cluster."
    exit 1
fi