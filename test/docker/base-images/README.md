# Bedrock Test Base Image

This is the base image used for running terratest based unit and integration GO tests. This image comes pre-packaged with the following dependencies:
* Go programming language: Terraform test cases are written in [Go](https://golang.org/dl/).
* dep: [dep](https://github.com/golang/dep#installation) is a dependency management tool for Go.
* Azure CLI: The [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) is a command-line tool you can use to manage Azure resources. (Terraform supports authenticating to Azure through a service principal or via the Azure CLI.)
* mage: We use the mage go [module](https://github.com/magefile/mage#installation) to show you how to simplify running Terratest cases.

## Getting Started

You can build this image locally using a different golang version following the example below.

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

#### Image Build Parameters

**gover**

Golang version specification. This argument drives the version of the `golang` stretch base image.

**tfver**

Terraform version specification. This argument drives which terraform version release this image will use.

```shell
docker build -f "test\docker\base-images\Dockerfile" -t msftcse/bedrock-test-base:1.11 . --build-arg gover=1.11 tfver=0.11.13
```
## Contributing

Please read [CONTRIBUTING.md](../../../README.md#contributing) for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the MIT License - see the [LICENSE](../../../LICENSE) file for details.