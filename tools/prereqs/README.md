# Bedrock Prerequisites

Bedrock utilizes existing tools from the cloud and cloud native ecosystem.  You'll need to install the following prerequisites if you haven't already:

- Azure CLI
- Kubectl
- Helm
- Fabrikate
- Terraform
- Bedrock CLI

We maintain an individual script for each prerequisite to make this easier.

NOTE: You do not need to use these scripts if you are already utilizing a package manager like `apt` or `brew` to install these.

To use this, clone the bedrock repository locally and then navigate to `tools/prereqs` and execute the appropriate scripts for the prerequisites you need to install:

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

## Bedrock CLI

```bash
$ sudo ./setup_bedrock_cli.sh
```
