# Omakase

We are living in a virtual cambrian explosion of cloud native platforms that individually promise to greatly improve our lives as developers. At the same time, it is (currently) very difficult to start from stratch and stitch all of these projects together into a coherent whole.

In Japanese, Omakase means "I'll leave it up to you" and is commonly used to entrust a chef to design a dining experience for you that best utilizes their culinary skills and minimizes the stress on you, the diner so that you can focus on relaxing with the folks you are dining with.

In that vein, this project is our humble attempt to combine the collective wisdom of our cloud native community for building best practice cloud native Kubernetes clusters. It is based on the real world experience that we have of deploying cloud native applications at Microsoft and with our largest customers. That said, we do not claim to have all the answers (and recognize that there many pieces missing) and would greatly appreciate your ideas (and pull requests!)

## What's in the box?

Omakase is a currently set of Terraform based devops scripts for automated deployment of the best production-ready cloud native platforms on a Kubernetes cluster including:

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

-   [Traefik](https://traefik.io/) ingress controller automatically integrated with Jaeger.

Distributed Tracing

-   [Jaeger](https://www.jaegertracing.io/) end to end distributed tracing.

## Getting Started

1. Install the following tool dependencies per their instructions below for your platform and ensure that they are in your path.

-   [terraform](https://www.terraform.io/intro/getting-started/install.html)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
-   [helm](https://helm.sh/)

2. If you haven't, create a new Kubernetes cluster with RBAC enabled and switch to it such that it is the default context `kubectl` is using.

3. Clone this project locally:

```
$ git clone https://github.com/Microsoft/omakase
```

4. Check that everything is setup correctly:

```
$ tools/check-prereqs
```

5. Choose a password for your grafana deployment and deploy the dev configuration. This will take a while. I recommend making yourself a delicious cup of coffee as a reward.

```
$ export TF_VAR_grafana_admin_password="SECRET4ever"
$ ./deploy dev
```

6. Take it for a test spin!

```
$ tools/grafana

NOTE: By default the credentials for grafana are 'ops' and the password you chose above.
```

Grafana is already connected to our cluster's Prometheus service and we've included a couple of dashboards so you can start monitoring the critical metrics in your Kubernetes cluster right away.

![Grafana Image](./docs/images/grafana.png)

```
$ tools/kibana
```

Omakase has configured a full Fluentd, Elasticsearch, and Kibana logging stack ready for you to create your first index and start querying and visualizing text logs immediately.

![Kibana Image](./docs/images/kibana.png)

```
$ tools/traefik
```

Traefik is configured as an ingress controller and it includes a management console for monitoring the health and performance of your externally exposed services.

![Traefik Image](./docs/images/traefik.png)

# Contributing

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
