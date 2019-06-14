## Rings

This README serves to explain a Ring based deployment using Fabrikate and Bedrock without using a Service Mesh.

The Ring workflow is shown in the following diagram, where you will see that it represents an extension to the Bedrock CI/CD.

![Ring Workflow](./images/ring-workflow.png)

There are a few additions made to the Bedrock CI/CD to account for this Rings implementation:

1. Ring.yaml
2. Ring Operator
3. Flatpack HLD Repo

### Ring.yaml
As a ring is considered to be strictly a revision of a microservice, we need a way to configure the ingress controller to route to the microservice revision a user belongs to. We achieve this by providing a `ring.yaml` file in our helm chart, which is an abstraction on Kubernetes and Traefik primitives.

An example ring.yaml is as follows

```
apiVersion: apps/v1
kind: Ring
metadata:
 name: myBranch
 deployable: true or false
spec:
 # Turnstile data (Custom Claims)
 claim: edge-users
 entryPoints:
 # Source of traffic (eg: 80 or 443)
 - web
 - web-secured
 routes:
 - PathPrefix(`/query/v1`) && Headers(`x-ring`, `myBranch`)
 selector:
   # Target deployment instances
   # name of microservice
   name: publish
   # Major version of microservice
   version: v1
   # Branch name
   ring: myBranch
```

### Ring Operator
The ring.yaml is consumed by a custom resource controller, which we call the Ring Controller. The Ring Controller sets up two resources on the cluster that map traffic to the proper service revision: a Traefik Ingress Route that maps path and headers to a Kubernetes service, and a Kubernetes service that maps to the microservice deployment.

### Git Repositories

Recall that in the official Bedrock CI/CD (without Rings), there exists three repositories: (1) Service Source Code (2) Service HLD and (3) the Materialized Manifest. The concept of Rings introduces a *new* repository to the workflow, the Flatpack HLD. Altogether, the following exists in the Rings workflow:

For every independent service we assume 2 git repositories exist:

**Service Source Repository**: A git repository that maintains the source code of the service, a dockerfile, and a helm chart. Developers will commit regularly to this repository, with revisions and rings being tracked in Git branches.

**Service HLD Repository**: A second git repository that maintains a High Level Definition for the source repository. Commits to this repository are automated, and configuration is performed via AzDo pipelines. Subcomponents in this repository map to the branches in the Service Source Repository

For all services represented by the above 2 git repositories, we assume two more repositories exist:

**“Flatpack” HLD Repository**: A git repository that maintains a High Level Definition for all Services and Revisions that are intended to be run on the Cluster.

**“Materialized” Manifest Repository**: this git repository acts as our canonical source of truth for Flux – the in-cluster component that pulls and applies Kubernetes manifests rendered from the “flatpack” HLD repository.
