# Operating Multiple Services

> *Please first overview the [Pipeline Thinking](./PipelineThinking.md) document before continuing through this document.*

## Overview: GitOps

In our prescribed gitops workflow, you are expected to push changes to your cluster through changes to a HLD repository.

Recall the prescribed workflow that encompasses the manifest yaml generation pipeline:

![Example of manifest yaml generation pipeline](images/manifest-gen.png)
<p align="center"><i>Example of manifest yaml generation pipeline</i></p>

In the above diagram, a change (manual or automatic) to the first HLD repository should trigger a CI process, which invokes Fabrikate and composes configuration onto the HLD, transforming it into manifests that a Kubernetes cluster can consume via Flux.

## Multiple Services

When you operate multiple microservices, you may wish to isolate your source code for each microservice into their own repository.

This has a number of advantages:

- A source repository describes only the source code for a single microservice
- A repository's commit history will accurately describe the lifecycle of development for the microservice

Thus, you may wish to extend the yaml generation pipeline to encompass the desire to build and deploy multiple microservices to a Kubernetes cluster via gitops.

### Structuring a Cluster HLD

Let's examine a scenario in which you have two microservices, `A` and `B`, and for each microservice, you operate a Git repository, containing any source code for that repository.

For this setup, we prescribe an HLD that belongs in a seperate Git repository, which identifies the microservices that must run in your cluster. When this HLD is built with Fabrikate, the materialized repository will be rendered to yaml files that identify the running cluster microservices.

A HLD that builds both microservices `A` and `B` could be as follows:

```yaml
name: my-cluster-hld
type: helm
subcomponents:
- name: svc-a
  type: helm
  source: https://github.com/contosocorp/helm-charts
  method: git
  path: svc-a-helm
- name: svc-b
  type: helm
  source: https://github.com/contosocorp/helm-charts
  method: git
  path: svc-b-helm
```

In the above HLD, we declare two subcomponents, `svc-a`, and `svc-b`. Each subcomponent is of type `helm`, meaning the source path references a buildable helm chart for each of the two microservices, `A`, and `B`, that must be able to deploy against a Kubernetes cluster. These helm charts live in a seperate Git repository which provides the added advantage of seperating Kubernetes configuration from the application source


![Structure of a Component with multiple microservices](images/hld-svc-a-svc-b.png)

### Configuring a microservice

The next step would be to configure the subcomponents to configure the helm chart each references. Recall that Fabrikate reads configuration provided in the config directory of a Component, and how [the manifest generation pipeline for a single service](#overview-gitOps), configures the image tag for a built service. Similarly, we can configure the cluster HLD to reference a built container image from a microservice source repository:

![Example of a manifest yaml generation pipeline with multiple microservices](images/svc-a-svc-b.png)

We expect that any changes produced on `A` or `B` will run a pipeline that will:

1. Build a docker container image in the microservice repository
2. Push the docker container image to a container registry
3. Pull request a change on the HLD that configures the microservice's matching subcomponent

### Complete Deployment

![Example of the complete workflow from committing to a source repository, to generating the k8s yaml](images/src-to-k8s-pipeline.png)

The above diagram describes the idealized complete workflow for committing to a microservice repository to congfiguring and generating Kubernetes manifests, taking advantage of multiple microservice source repositories.

### Repositories

With the introduced complexity of operating multiple ,microservices with Gitops, we need to quantify the number of git repositories necessary for orchestrating and configuring multiple repositories.

- For *every* microservice that you would like to be orchestrate via Gitops, you will need a Git repository that identifies its source code. eg; for **N** services, **N** git repositories are necessary.

- A single helm chart repository to capture helm charts and basic configuration for the microservices intended to be deployed

- A single repository to encapsulate the HLD for the microservices intended to be run on a cluster, each of those referencing a helm chart in the helm chart repository.

- A single "materialized" manifest repository, to render the HLD repository to. This repository will be observed by Flux, the on-cluster daemon that reconciles manifests.

In short:

```
total git repositories = N + 3
```

## Further Reference

The following resources identify how one may set up their own pipelines to automatically configure HLD repositories when a new container image is published:

+ [Manifest Generation Pipeline](azure-devops/ManifestGeneration.md)
+ [Image Tag Release Pipeline](azure-devops/ImageTagRelease.md)
