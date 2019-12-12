# Bedrock and SPK Prerequisites

Bedrock builds on top of the work of a number of other tools.  As such, you'll need to install the following tool prerequistites if you haven't already.

- Azure CLI
- Kubectl
- Helm
- Fabrikate
- Terraform
- SPK

To make this easier, we provide an individual script for each prereq. NOTE: You do not need to use these scripts if you are already utilizing a package manager like `apt` or `brew` to install these. Most of the install scripts install the executables into /usr/local/bin.

To use, clone the bedrock repository locally and then navigate to `tools/prereqs`.

## Azure CLI

```bash
$ sudo ./setup_azure_cli.sh
```

## kubectl

```bash
$ sudo ./setup_kubectl.sh
```

## Helm

```bash
$ sudo ./setup_helm.sh
```

## Fabrikate

```bash
$ sudo ./setup_fabrikate.sh
```

## Terraform

```bash
$ sudo ./setup_terraform.sh
```

## SPK

```bash
$ sudo ./setup_spk.sh
```
