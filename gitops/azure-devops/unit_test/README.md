# Unit Testing
A unit test framework for shell scripts that relies on [shUnit2](https://github.com/kward/shunit2). The unit test will perform checks to ensure various components of `build.sh` runs as expected. 

## Prerequisites

This unit test makes the following assumptions:

- The user has an existing AKS Manifest repository (e.g. [yradsmikham/k8s](https://github.com/yradsmikham/k8s))
- A Personal Access Token is generated that grants permission to read/write to the AKS Manifest repo.

## Instructions

1. Clone this repository.
2. `cd gitops/azure-devops/unit_test/`
3. Run `git clone https://github.com/kward/shunit2.git`
4. Provide values to environment variables in `environment.properties`.
5. Run `./unit_test.sh`
