# Bedrock and SPK Prerequisites

Bedrock utilizes many existing tools in the ecosystem, and if you haven't already, you'll need to install the following prerequistites:

- Azure CLI
- Kubectl
- Helm
- Fabrikate
- Terraform
- SPK

To simplify this, we maintain an individual script for each prerequisite.

NOTE: You do not need to use these scripts if you are already utilizing a package manager like `apt` or `brew` to install these.

To use, clone the bedrock repository locally and then navigate to `tools/prereqs` and execute the appropriate scripts for the prerequisites you need to install.

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
