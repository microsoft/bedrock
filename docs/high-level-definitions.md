# High Level Deployment Definitions

In [Why GitOps?](./why-gitops.md) we discussed how the git repo of record contains the low level Kubernetes resource manifests and that commits against this repo are reconciled with Kubernetes by Flux to bring the cluster into the same state. We also saw in our [first workload walkthrough](../firstWorkload) how we could commit a simple set of resource manifests to this repo and that Flux would reconcile that change with the cluster.

In the real world, however, the Kubernetes resource manifests that comprise an application definition are typically very complex. For example, the resource manifests needed to deploy ElasticSearch can run to 500+ lines and the complete deployment of an Elasticsearch / Fluentd / Kibana (EFK) logging stack can be over 1200 lines. These resource manifests, by their YAML nature, are typically very dense, context free, and very indentation sensitive -- making them a dangerous surface to directly edit without introducing a high risk for operational disaster.

This has traditionally been solved in the Kubernetes ecosystem with higher level tools like [helm](http://helm.sh). Helm provides templating for the boilerplate inherent in these resource definitions and also provide a reasonable set of default configuration values. Helm continues to be the best way to generate the resource manifests for applications, and we use Helm in our GitOps CI/CD process, checking the generated resource manifests into the resource manifest git repo that we described previously.

That said, a second problem that you have to address when you start to compose a real world production Kubernetes deployment is that the resource manifests that describe the in-cluster workload tend to be composed of the combination of many Helm charts.  For example, to deploy the EFK logging stack above, you might want to generate resource manifests using four charts from helm/charts:  `stable/elasticsearch`, `stable/elasticsearch-curator`, `stable/fluentd-elasticsearch`, and `stable/grafana`.

While you could utilize shell scripts to do this or even create a large helm with subdependencies, this is brittle and not easy to share between deployments, something that is essential in large company contexts where they may have hundreds of clusters running and where reuse, leverage, and central maintenance is critical.

In Bedrock, we’ve taken another approach, instead utilizing higher level components in our deployment, which collects one or more subcomponents such that can be referenced in a higher level deployment definition. Such a stack for the above EFK logging stack might look like:

```json
{
    "name": "elasticsearch-fluentd-kibana",
    "type": "static",
    "path": "./manifests",
    "subcomponents": [
        {
            "name": "elasticsearch",
            "type": "helm",
            "source": "https://github.com/helm/charts",
            "method": "git",
            "path": "stable/elasticsearch"
        },
        {
            "name": "elasticsearch-curator",
            "type": "helm",
            "source": "https://github.com/helm/charts",
            "method": "git",
            "path": "stable/elasticsearch-curator"
        },
        {
            "name": "fluentd-elasticsearch",
            "type": "helm",
            "source": "https://github.com/helm/charts",
            "method": "git",
            "path": "stable/fluentd-elasticsearch"
        },
        {
            "name": "kibana",
            "type": "helm",
            "source": "https://github.com/helm/charts",
            "method": "git",
            "path": "stable/kibana"
        }
    ]
}
```

Such a deployment specification requires tooling and the Bedrock project maintains a tool called Fabrikate to generate the low level resource manifests from these high level definitions. It is intended to be executed as part of a CI/CD pipeline that sits between a high level definition of your deployment and the resource manifest repo that Flux watches. This enables the components of a deployment to be written at a higher (and hence less error prone) level and to be able to share those components amongst deployments.

TODO: Diagram of High Level Definition Repo, CI/CD, to Resource Manifest Repo

A final problem that Fabrikate solves is that, in real world scale workloads, there are often multiple clusters deployed for the same workload for scale, reliability, and/or latency reasons. These clusters tend to only differ slightly in terms of their config and there is a strong desire to centralize the common config for these clusters such that it remains DRY.

Fabrikate solves this with composable configuration files. These configuration files are loaded and applied at generation time to build the final set of configuration values that are used during `helm template`. Using our EFK stack example from above, and since we know the different subcomponents that make up this stack, we can preconfigure the connections between these different subcomponents with config values with a configuration file that looks like this such that we can do this once in one spot:

```yaml
config:
subcomponents:
  elasticsearch:
    namespace: elasticsearch
    injectNamespace: true
  elasticsearch-curator:
    namespace: elasticsearch
    injectNamespace: true
    config:
      cronjob:
        successfulJobsHistoryLimit: 0
      configMaps:
        config_yml: |-
          ---
          client:
            hosts:
              - elasticsearch-master.elasticsearch.svc.cluster.local
            port: 9200
            use_ssl: False
  fluentd-elasticsearch:
    namespace: fluentd
    injectNamespace: true
    config:
      elasticsearch:
        host: "elasticsearch-master.elasticsearch.svc.cluster.local"
  kibana:
    namespace: kibana
    injectNamespace: true
    config:
      elasticsearchHosts: "http://elasticsearch-master.elasticsearch.svc.cluster.local:9200"
```

Fabrikate also enables you to override configuration such that you can utilize the same high level definition with a `common` set of configuration, but also differentiate the configuration applied to the `prod-east` and `prod-west` clusters with specific `prod-east` and `prod-west` configuration that preempts this `common` configuration.

Our EFK preconfigured stack above can be itself checked into a git repo and referenced from another high level deployment definition file.  For example, if we wanted to define a “cloud native” stack with all of the observability, service mesh, and management components included, we could express this with a deployment config that looks like:

```yaml
name: "cloud-native"
type: static
path: "./manifests"
subcomponents:
  - name: "elasticsearch-fluentd-kibana"
    source: "../elasticsearch-fluentd-kibana"
  - name: "prometheus-grafana"
    source: "../prometheus-grafana"
  - name: "linkerd2"
    source: "../linkerd2"
  - name: "kured"
    source: "../kured"
  - name: "jaeger"
    source: "../jaeger-operator"
  - name: "traefik"
    source: "../traefik"
```

Such a hierarchical approach to specifying deployments allows for the reuse of lower level stacks (like the EFK example above) and for updates to these dependent stacks to be applied centrally at the source -- as opposed to having to make N downstream commits in each deployment repo.

As we mentioned previously, Fabrikate is typically used as part of a CI/CD pipeline with the high level definition at one end and the resource manifest repo at the other end.  Both the high level definition and resource manifest repos are backed by git repositories that provide an audit trail. The input git repo can follow a branch, commit, pull request model, and this approach makes it also easy to implement rollbacks.

TODO: HLD to RM repo to Flux in-cluster Figure
