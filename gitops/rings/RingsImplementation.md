# Rings Implementation

This guide intends to implement Rings on Kubernetes without a Service Mesh using Azure DevOps. We recommend you review the [Rings Model](./README.md) to understand the design of this ringed model before attempting to implement it.

**Note**: For now, the implementation only supports GitHub repos.

### Service HLD to Materialized Manifest

The Service HLD to Materialized Manifest pipeline resembles the [Manifest Generation Pipeline](https://github.com/microsoft/bedrock/blob/master/gitops/azure-devops/ManifestGeneration.md) with the **requirements** to specify the following environment variables:

```
HLD_PATH= the git url to the Flatpack HLD repo
(e.g. https://github.com/bnookala/hello-rings-flatpack)

MANIFEST_REPO= the git url to the materialized manifest repo
(e.g. https://github.com/bnookala/hello-rings-flatpack-materialized)
```

The Service HLD to Materialized Manifest repo pipeline is initiated by a pull request that the Image Tag Release pipeline will create. A user will need to merge the pull request in order to cause this pipeline to build.

### FlatPack HLD to Materialized Manifest

As described in the [Rings Model](./README.md) documentation, the idea of using a Flatpack HLD is to have a repository that maintains the High Level Definition for **all** services and revisions that are intended to be run on the cluster.

It is important to note that the Flatpack HLD to manifest pipeline build does *not* run every time the CI/CD process is invoked. The FlatPack HLD is a unique HLD that is **only** deployed when a new Ring is to be added to the cluster. The following example is a Flatpack HLD that consists of two services, the `hello-rings` and the `ring-operator`, each service with its own ring.

```
name: hello-rings-flatpack
subcomponents:
- name: hello-rings
  type: component
  source: https://github.com/bnookala/hello-rings-hld
  method: git
  branch: master
- name: ring-operator
  type: component
  source: https://github.com/samiyaakhtar/ring-operator
  method: git
  branch: master
```
The Flatpack will need to be modified by the user when a new service(s) or branch of a service (ring) is to be added. The new service will be added as a subcomponent in the `component.yaml` file. Often, multiple rings derived from the same service will be created and is differentiated by git branches.

To incorporate the Flatpack HLD into the Bedrock Rings CI/CD, you will need to configure another manifest generation pipeline, but this time using the Flatpack HLD, instead of a Service HLD, writing to the *same* materialized manifest repo used in the Service HLD to Materialized Manifest pipeline.

Unlike the Service HLD to Materialized Manifest pipeline, you will only need to specify the `MANIFEST_REPO` here.
