#!/bin/bash

echo "Installing helm"
curl -LO https://git.io/get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
apt-get update
apt-get install wget
apt-get install unzip

echo "https://raw.githubusercontent.com/microsoft/bedrock/master/gitops/azure-devops/build.sh > gitops.sh"
curl https://raw.githubusercontent.com/microsoft/bedrock/master/gitops/azure-devops/build.sh > gitops.sh

echo "chmod +x ./gitops.sh"
chmod +x ./gitops.sh

echo "./gitops.sh"
./gitops.sh
