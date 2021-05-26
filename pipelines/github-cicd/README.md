# Terraform Deployments on Github actions

This repository contains CICD templates that can deploy [Terraform](https://www.terraform.io/) templates for production systems into Azure using Github actions.

## Automated CICD

Deployment of Terraform Templates are fully automated via the [Github actions workflow](./.gh-actions-ci.yml).

**Terminology**

* `init` causes Terraform modules to be downloaded/cached
* `lint` applies lint checks to the IAC templates and any Go files
* `build` is a Terraform plan
* `release` is a Terraform apply

The table below outlines when a deployment will happen to each stage:

> **Note**: Manual approvals are **always required** before deploying to non-`dev` environments

| Action | Pipeline Stages (sequential) |
| --- | --- |
| Manual branch build | `dev::build`, `dev::release` |
| Create/Update PR | `init`, `lint`, `dev::build`, `dev::release` |
| Merge PR | `init`, `lint`, `dev::build`, `dev::release`, `integration::build`, `integration::release`, `prod::build`, `prod::release` |
| Master Branch Build | Same as above |

## Infrastructure Rollbacks

It is possible that Terraform deployments will need to be rolled back. To rollback use `git revert` commands or simply make another commit to return your configuration to a previous state in the infrastructure as code repository.

Be sure to create a local git branch, then commit, push, and generate a pull request on Github.

## Usage

**Step 1: Azure & Github Configuration**

All Azure and Github configuration required to use these templates should be provisioned using the [`github-bootstrap-iac-cicd`](https://github.com/microsoft/cobalt/tree/master/infra/templates/github-bootstrap-iac-cicd) template from project [Cobalt](https://github.com/microsoft/cobalt). No other manual configuration is necessary.

**Step 2: Build and Push Github Runner Base Image**

The CICD templates in this folder assume the following tools are installed.
* Terraform v0.12.x
* Golang
* Azure CLI

The included [`Dockerfile.sample`](Dockerfile.sample) can be used as a starting point. Use these commands to push the base image to the ACR:

```bash
# Configure environment
$ ACR_NAME="..."
$ IMAGE="..."
$ TAG="latest"

# Build and push image
$ az acr login -n "$ACR_NAME"
$ docker build -f Dockerfile.sample . -t "$ACR_NAME.azurecr.io/$IMAGE:$TAG"
$ docker push "$ACR_NAME.azurecr.io/$IMAGE:$TAG"
```

**Step 3: Configure Github Workflow to Use Base Image**

Now insert a custom value for the base image reference/property in `.gh-actions-ci.yml`:

> **Note**: The use of `\$CI_REGISTRY` in the command below is intentional. When this pipeline is exercised, the value of `CI_REGISTRY` will be resolved because the [`github-bootstrap-iac-cicd`](https://github.com/microsoft/cobalt/tree/master/infra/templates/github-bootstrap-iac-cicd) template from step 1 configured it to point to the correct container registry.

```bash
$ sed -i '' "s/{{IMAGE_SLUG}}/\$CI_REGISTRY\/$IMAGE:$TAG/g" .gh-actions-ci.yml
```

**Step 4: Write Some Terraform!**

At this point, you can begin writing a Terraform template for your deployment. The [`sample.tf`](./sample.tf) file is a sample Terraform template that shows a simple but working Terraform file that uses the backend state and variables configured through the Github/Azure bootstrapping process referenced above.
