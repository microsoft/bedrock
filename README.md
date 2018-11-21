# bedrock

The cloud native ecosystem is in a virtual cambrian explosion of platforms and projects that individually promise to greatly improve our lives as developers. At the same time, even as an experienced developer in this space, it is difficult to start from stratch and stitch all of these projects together into a coherent whole without having to do a substantial amount of research and work.

This project is our humble attempt to combine the collective wisdom of our cloud native community for building best practice cloud native Kubernetes clusters. It is based on the real world experience that we have of deploying cloud native applications with our largest customers.

## What's in the box?

Bedrock is a set of Terraform based devops scripts for automated deployment of the common elements of a production-ready cloud native Kubernetes cluster. It currently includes:

Cluster Management

-   [Kured](https://github.com/weaveworks/kured) (automatic cordon/drain/reboot after node level patches are applied)

Monitoring

-   [Prometheus](https://prometheus.io/) metrics monitoring and aggregation
-   [Grafana](https://grafana.com/) metrics visualization with Kubernetes monitoring dashboards preconfigured

Log Management

-   [Fluentd](https://www.fluentd.org/) collection and forwarding
-   [Elasticsearch](https://www.elastic.co/) aggregation
-   [Kibana](https://www.elastic.co/products/kibana) querying and visualization

Traffic Ingress

-   [Traefik](https://traefik.io/) ingress controller (including Jaeger integration)

Distributed Tracing

-   [Jaeger](https://www.jaegertracing.io/) end to end distributed request tracing.

## Quick Start

1. Install the following tool dependencies per their instructions below for your platform and ensure that they are in your path.

-   [terraform](https://www.terraform.io/intro/getting-started/install.html)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
-   [helm](https://helm.sh/)

2. If you haven't, create a new Kubernetes cluster with RBAC enabled and switch to it such that it is the default context `kubectl` is using.

3. Clone this project locally:

```
$ git clone https://github.com/Microsoft/bedrock
```

4. Check that everything is setup correctly:

```
$ tools/check-prereqs
```

5. Choose a password for your grafana deployment and deploy the dev configuration.

```
$ export TF_VAR_grafana_admin_password="SECRET4ever"
$ cd infra
$ ./deploy dev
```

6. Take it for a test spin!

```
$ tools/grafana

NOTE: By default the credentials for grafana are 'ops' and the password you chose above.
```

Grafana provides a visualization of the metrics being collected by our cluster's Prometheus service -- and we've included a couple of Kubernetes related dashboards out of the box.

![Grafana Image](./docs/images/grafana.png)

```
$ tools/kibana
```

Fluentd, Elasticsearch, and Kibana are installed and integrated with each other and your cluster -- ready for you to start querying and visualizing text logs immediately.

![Kibana Image](./docs/images/kibana.png)

```
$ tools/traefik
```

Ingress traffic to the cluster is managed by Traefik, which includes a management console for monitoring the health and performance of your externally exposed services.

![Traefik Image](./docs/images/traefik.png)

```
$ tools/jaeger
```

Jaeger provides distributed tracing of requests through your system so you can discover and optimize performance hotspots.

![Jaeger Image](./docs/images/jaeger.png)

# Contributing

We do not claim to have all the answers (and recognize that there many pieces still missing) and would greatly appreciate your ideas and pull requests.

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

For project related questions or comments, please contact (Tim Park)[https://github.com/timfpark].
