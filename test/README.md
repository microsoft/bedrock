# Cluster Validation Testing in Bedrock

## Summary

This section describes how to build integration and validation tests for your bedrock cluster environments using the Go testing packages and the terratest modules.

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code. It provides a variety of helper functions and patterns for common infrastructure testing tasks.

In addition, the bedrock test suite allows for better collaboration with embedding into CI/CD tools such as Travis or Azure DevOps Pipelines.

## Prerequisites

Please [install bedrock required tools](/cluster/README.md/#required-tools) in addition to the following:

- [Golang](https://golang.org/doc/install) 1.11 or later
- [Dep](https://github.com/golang/go/wiki/PackageManagementTools) Optional, but required for now in order for VSCode intellisense and linting to work. [See issue 2317](https://github.com/Microsoft/vscode-go/issues/2317#issuecomment-479106825).

## Test Setup Locally

In this example we are using the [`azure-simple`](/cluster/environments/azure-simple/readme.md) for a template integration test.

### Setup for linux users

1. Install Go using:

    `sudo snap install --classic go`

1. Run `go get -m github.com/microsoft/bedrock/test` and navigate to the bedrock test repository in the `/go/src/github.com/microsoft/bedrock/test` directory in the `$GOPATH`

1. Change _all_ instances of the module source in the `main.tf` file pointing to `github.com/Microsoft/bedrock/cluster` to be your local development path `../..`.

    i.e. `source = "github.com/Microsoft/bedrock/cluster/azure/aks-gitops"` becomes `source = "../../azure/aks-gitops"`

    Otherwise the tests will go against the code which is in the master branch in the GitHub repository.

1. Provide values for the environment variables and export for authenticating Terraform to provision resources within your subscription.

    ```shell
    export ARM_CLIENT_ID="${clientid}"
    export ARM_CLIENT_SECRET="${clientsecret}"
    export ARM_SUBSCRIPTION_ID="${subscriptionid}"
    export ARM_TENANT_ID="${tenantid}"
    export DATACENTER_LOCATION="${location}"
    export ssh_key=$(readlink -f id_rsa)
    export public_key=$(cat id_rsa.pub)
    ```

1. Run `go test -v -timeout 99999s` to execute all tests in your test suite. Or run `go test -v -run <You_Test_Name> -timeout 999999s` to run a targeted test.

1. (Optional) Install Deps

    Install Dep with:
    `curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh`

    Then install the dependencies to the traditional path via running this from the test directory:
    `dep ensure`

## Test Setup CI/CD

For test setup using a continuous integration pipeline, refer to the [azure-pipelines.yaml](../azure-pipelines.yml) for how to configure your agent, setup script for installing prerequisites and executing scripts. Be sure to add the environment path your test is leveraging to the CI yml. For example `paths/include:` section in the `azure-pipelines.yml`.
