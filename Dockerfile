FROM debian:stretch
LABEL creator="https://twitter.com/carlesanagustin"

RUN apt-get update && \
    apt-get install -y unzip
# RUN apt-get install -y git curl wget apt-transport-https lsb-release gpg build-essential

COPY ./tools/prereqs/*.sh /

RUN /setup_azure_cli.sh && \
    /setup_bedrock_cli.sh && \
    /setup_fabrikate.sh && \
    /setup_helm.sh && \
    /setup_kubectl.sh && \
    /setup_terraform.sh

RUN rm -f /*.sh && \
    apt-get purge -y unzip && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]