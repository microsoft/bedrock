# Cluster Validation Testing in Bedrock

## Summary

This section describes how to build integration and validation tests for your bedrock cluster environments using the Go testing packages and the terratest modules.

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code. It provides a variety of helper functions and patterns for common infrastructure testing tasks.

In addition, the bedrock test suite allows for better collaboration with embedding into CI/CD tools such as Travis or Azure DevOps Pipelines.

## Prerequisites

Please [install bedrock required tools](/cluster/README.md/#required-tools) in addition to the following:

- [Go](https://golang.org/doc/install)
- [Dep](https://github.com/golang/go/wiki/PackageManagementTools)
- [Terratest Modules](https://github.com/gruntwork-io/terratest)
- CI/CD Tool (Optional)

## Test Setup Locally

In this example we are using the [`azure-simple`](/cluster/environments/azure-simple/readme.md) for a template integration test.

### Setup for linux users:

1. Install Go using:

> `sudo snap install --classic go`

2. Install Dep using:

> `curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh`

3. Run `go get github.com/microsoft/bedrock` and navigate to the bedrock test repository in the `/go/src/github.com/microsoft/bedrock/test` directory in the `$GOPATH`

4. Provide values for the environment variables and export for authenticating terraform to provision resources within your subscription.

``` sh
export ARM_CLIENT_ID="${clientid}"
export ARM_CLIENT_SECRET="${clientsecret}"
export ARM_SUBSCRIPTION_ID="${subscriptionid}"
export ARM_TENANT_ID="${tenantid}"
export DATACENTER_LOCATION="${location}"
export ssh_key=$(readlink -f id_rsa.pub)
export public_key=$(cat id_rsa.pub)
```

5. Run `dep init` which will make educated guesses about what versions to use for your dependencies, generates a `Gopkg.toml`

> If you run into `dep init` hanging indefinitely, create an empty `Gopkg.toml` file and `dep ensure` will pull the correct dependencies. [#1896](https://github.com/golang/dep/issues/1896)

6. Run `dep ensure`

7. Run ` go test -v -timeout 99999s`

## Test Setup CI/CD

For test setup using a continuous integration pipeline, refer to the [azure-pipelines.yaml](../azure-pipelines.yml) for how to configure your agent, setup script for installing prerequisites and executing scripts.
