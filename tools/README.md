# Bedrock Tools

This directory contains tools for working with both the release process as well as helping to facilitate pull requests, especially when remote references to modules need to be updated.

Currently, the scripts are:

- `bedrock_terraform_release.sh` - this script updates remote references and creates a branch for which releases can be generated
- `toggle_remote_ref.sh` - this script is used to toggle remote references in your repository so when a PR is issued with changes affecting remote modules, those changes (in the branch the PR is based on) can be toggled easily for testing (and then returned to reference master post testing)

## Dockerfile with Bedrock prerequisites

### Description

This Dockerfile creates a Debian image with all Bedrock prerequisites `prereqs/setup*.sh` installed ready to use from any Docker based system. It is composed of a `Dockerfile` with the image definition and a `Makefile` with all Docker CLI instructions.

### Requirements

* `make`: [https://www.gnu.org/software/make/](https://www.gnu.org/software/make/)
* `docker`: [https://docs.docker.com/](https://docs.docker.com/)

### Instructions

* Build docker image: `make d_build`
* Run docker container and get bash in it: `make d_run`
* Remember you can use this image to run any prerequisite command with `docker run [OPTIONS] bedrock:latest terraform [ARG...]`