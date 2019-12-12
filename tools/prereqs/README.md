# Bedrock and SPK Prerequisites

Working with Spk and Bedrock in general requires a set up prerequisites to be installed.  Those prerequisites are as follows:

- Azure CLI
- Kubectl
- Helm
- Fabrikate
- Terraform
- SPK

In order to facilitate the ease of installing these requirements, a set of scripts has been created that will install each prereq individually.  The majority of the install scripts install the executables into /usr/local/bin.  In the case of the Azure CLI, if the "manual" install method is used, you will be prompted where `az` will be installed.

The scripts can be found [here](./).
