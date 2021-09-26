#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# Update the VARIANT arg in devcontainer.json to pick an Ubuntu version: 20.04, 18.04
# To fully customize the contents of this image, use the following Dockerfile instead:
# https://github.com/microsoft/vscode-dev-containers/tree/v0.122.1/containers/ubuntu/.devcontainer/base.Dockerfile
ARG VARIANT="18.04"

FROM mcr.microsoft.com/vscode/devcontainers/base:0-ubuntu${VARIANT}

ARG HELM_VERSION="v2.16.8"
ARG BEDROCK_VERSION="0.6.5"
ARG TERRAFORM_VERSION="0.12.26"

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends unzip apt-utils dialog 2>&1

# Install Azure CLI and Kubectl
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash \
    && az aks install-cli

# Install Helm
RUN wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && tar xvf helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && sudo mv linux-amd64/helm /usr/local/bin/

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/

# Install Fabrikate
   # Run FABRIKATE_FILE=`curl -s -L https://github.com/microsoft/fabrikate/releases/latest | grep "$arch" | sed -n "s/.*\(fab-v[0-9]*.[0-9]*.[0-9]*-$arch.zip\).*/\1/p" | sort -u`
    # && FABRIKATE_VERSION=`echo $FABRIKATE_FILE | sed -n 's/.*v\([0-9]*.[0-9]*.[0-9]*\).*/\1/p'` \
    # && curl -s -LO https://github.com/microsoft/fabrikate/releases/download/$FABRIKATE_VERSION/$FABRIKATE_FILE
    # && unzip $FABRIKATE_FILE -d /usr/local/bin \

# Install Bedrock CLI
RUN curl -s -LO https://github.com/microsoft/bedrock-cli/releases/download/${BEDROCK_VERSION}/bedrock-linux \
    && cp bedrock-linux /usr/local/bin/bedrock \
    && chmod +x /usr/local/bin/bedrock