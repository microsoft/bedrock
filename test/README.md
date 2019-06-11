# Cluster Validation Testing in Bedrock

## Summary

This section describes how to build integration and validation tests for your bedrock cluster environments using the Go testing packages and the terratest modules.

Terratest is a Go library that makes it easier to write automated tests for your infrastructure code. It provides a variety of helper functions and patterns for common infrastructure testing tasks.

In addition, the bedrock test suite allows for better collaboration with embedding into CI/CD tools such as Travis or Azure DevOps Pipelines.

Included is an option to set up your environment using docker container to support bedrock deployments.

## Prerequisites

Please [install bedrock required tools](/cluster/README.md/#required-tools) in addition to the following:

- [Golang](https://golang.org/doc/install) 1.11 or later
- [Dep](https://github.com/golang/go/wiki/PackageManagementTools) Optional, but required for now in order for VSCode intellisense and linting to work. [See issue 2317](https://github.com/Microsoft/vscode-go/issues/2317#issuecomment-479106825).
- An Azure subscription
- A [service principal with `owner` role status](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- An [azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account?tabs=azure-portal) for tracking terraform remote backend state.
- [git](https://www.atlassian.com/git/tutorials/install-git)

## Test Setup Option: Local Machine

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
    export ARM_BACKEND_STORAGE_NAME="${storageaccount}"
    export ARM_BACKEND_STORAGE_KEY="${storagekey}"
    export ARM_BACKEND_STORAGE_CONTAINER="${storagecontainer}"
    export ssh_key=$(readlink -f id_rsa)
    export public_key=$(cat id_rsa.pub)
    ```

1. Run `go test -v -timeout 99999s` to execute all tests in your test suite. Or run `go test -v -run <You_Test_Name> -timeout 999999s` to run a targeted test.

1. (Optional) Install Deps

    Install Dep with:
    `curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh`

    Then install the dependencies to the traditional path via running this from the test directory:
    `dep ensure`

## Test Setup Option: Docker

The benefit with running the test suite through docker is that developers don't need to worry about setting up their local environment. 

#### Base Image Setup

Our test harness uses a base docker image to pre-package dependencies like Terraform, Go, Azure CLI, Terratest vendor packages, etc.

- **Optional Step** - Bedrock uses the public [msftcse/bedrock-test-base](https://hub.docker.com/r/msftcse/bedrock-test-base) base image by default. We also provide a utility script to generate a new base image.
- Rebuilding a new base image is as simple as running

```script
./test-harness/build-base-image.sh -g "<go_version>" -t "<terraform_version>"
```

> Note: Bedrock currently expects terraform version 0.11.x or newer.

##### Script Arguments

- `-g` | `--go_version`: Golang version specification. This argument drives the version of the `golang` stretch base image. **Defaults** to `1.11`.
- `-t` | `--tf_version`: Terraform version specification. This argument drives which terraform version release this image will use.. **Defaults** to `0.11.13`

Keep in mind that the terraform version should align with the version from the provider [module](/cluster/azure/provider/main.tf#L10)

- The base image will be tagged as:

```script
msftcse/bedrock-test-base:g${GO_VERSION}t${TERRAFORM_VERSION}
```

#### Local Run Script

Run the test runner by calling the below script from the project's root directory. This is one of two options.

```script
./test/local-run.sh
```

##### Script Arguments

- `-t` | `--template_name_override`: The template folder to include for the test harness run(i.e. -t "azure-simple"). When set, the git log will be ignored. **Defaults** to the git log.
- `-b` | `--docker_base_image_name`: The base image to use for the test harness continer. **Defaults** to `msftcse/bedrock-test-base:g${GO_VERSION}t${TF_VERSION}`.

## Test Setup CI/CD

**Linting** can be done for code style on terraform and golang files prior to commits using a git hook. Validate your modified changes are formatted prior to commits. A script can also verify that trailing whitespaces are removed. Bedrock confirms that these changes have been made as a step in our CI pipeline. This is done as a step in `azure-pipelines.yml`.

For test setup using a continuous integration pipeline, refer to the [azure-pipelines.yml](../azure-pipelines.yml) for how to configure your agent, setup script for installing prerequisites and executing scripts. Be sure to add the environment path your test is leveraging to the CI yml. For example `paths/include:` section in the `azure-pipelines.yml`.
