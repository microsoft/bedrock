# Why GitOps?

Kubernetes is, at its heart, a declarative system.  You apply definitions, typically described in YAML document form, of what you want to have exist in the cluster, and Kubernetes works to make that the current state of affairs.  More importantly, it works to keep it that way – working to restore this state through operational failures like the failure of a pod or failure of a node that hosts a set of pods.

A sample resource definition for a Service (which is the Kubernetes concept of an internal endpoint backed by a set of pods) looks like this:

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: user-service
  name: user-service
  namespace: services
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: user-service
  sessionAffinity: None
  type: ClusterIP
```

This declarative approach, and the textual format for these definitions, makes it a natural fit for being stored in source control. Using source control as the central system of record like this, known as GitOps, is increasingly being utilized for running large scale Kubernetes deployments in production.

In a GitOps based deployment, the cluster has a pod that is configured during the creation of the cluster to watch a specific git repo, where this git repo is designated to always contain the set of resource manifests that should be running in the cluster.

One such implementation of this approach (and the one we use in Bedrock) is Flux, a CNCF project.  It makes an outbound request to this manifest repo for changes and applies them to the Kubernetes cluster as shown in Figure 1.

Figure 1: Kubernetes cluster with Flux pulling from a git repo

There are two main security advantages to this pull based approach:
* Flux is able to verify with TLS that it is talking to the correct git repo (and not a man in the middle).
* We do not need to expose the Kubernetes API to manage what is running in our cluster, which is inherently more secure.

Besides matching up well with Kubernetes operating model and being more secure, building your operations with a GitOps workflow enables you to perform operational tasks in a style similar to a typical development workflow:

1. Pull Request based workflow: Your team can review each other’s operational changes just like you do with code level changes.
2. Point in time auditability into what is deployed in your cluster: Since the state of the git repo defines is what Flux will apply in Kubernetes, you have the ability to have point in time visibility into what was deployed on the cluster.
3. Understand operational changes between commits: As the workflow is based on git, you can inspect the exact set of changes that were made to the cluster.
4. Nonrepudiation of changes: The git commit log identifies who made a change and when they made it.
5. Easy disaster recovery: Since the current operational state of the cluster is storied in git, recovering from a lost cluster entails spinning up a new cluster and pointing it at the git repo.

These advantages make GitOps, in our opinion, a superior operational model to other traditional push based approaches based around `helm install` or `kubectl apply`.
