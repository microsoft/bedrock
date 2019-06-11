# Description: Base image used for running the golang terratest pipeline. 
# Usage: 
# build-
# docker build --rm -f "test/Dockerfile" \
#         -t msftcse/bedrock-test-base:1 . \
#         --build-arg build_directory="$BUILD_TEMPLATE_DIRS" \
#         --build-arg base_img_tag="$TEST_BASE_IMAGE_TAG"
# 
# Base image-
# ARG base_img_tag
# FROM msftcse/bedrock-test-base:$base_img_tag

ARG gover
FROM golang:${gover}-stretch as build
RUN apt-get update && \
    apt-get install -y git curl apt-transport-https lsb-release gpg



# Setup Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ stretch main" | \
    tee /etc/apt/sources.list.d/azure-cli.list

# Install Azure CLI + core compilers like gcc which are required for dep
RUN apt-get update && apt-get install -y build-essential wget unzip
ENV GOLANG_VERSION=$gover

ENV PATH /usr/local/go/bin:/usr/local/go:$PATH
ENV GOPATH $HOME/go
ENV GOBIN /usr/local/go
WORKDIR $GOPATH/src

# Install Terraform
ARG tfver
ENV TF_VERSION=$tfver
RUN wget --quiet https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
  && unzip terraform_${TF_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TF_VERSION}_linux_amd64.zip

# Go dep!
RUN /bin/bash -c "curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh"

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin/kubectl

# Install Helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh \
  && chmod 700 get_helm.sh
RUN ./get_helm.sh

# Setup go app workspace
 WORKDIR $GOPATH/src/app

# Copy over go unit / int tests + mage manifest
# ADD /test/*.go ./
ADD /test/* ./
RUN mkdir cluster build
ADD cluster/ ./cluster

RUN apt-get purge -y wget build-essential wget unzip curl \
    apt-transport-https lsb-release gpg

# Pull down golang vendor dependenies
RUN ls
RUN pwd
# RUN ["dep", "init", "-v"]
RUN ["dep", "ensure", "-vendor-only", "-v"]
RUN rm -r ./cluster

CMD bash