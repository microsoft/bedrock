# bedrock

Bedrock is a set of automation, tooling, and infrastructue stacks for deploying production-level Kubernetes 
clusters with a secure and auditable GitOps workflow.

This project is our humble attempt to combine the collective wisdom of our cloud native community for 
building best practice cloud native Kubernetes clusters, based on real world experience of 
deploying and operating cloud native applications.

## What's in the box?

Bedrock, by default, includes the workflow, platforms, and tools that we believe are the best in class for 
operating a Kubernetes cluster. It includes Terraform scripts for creating the core infrastructure for your cluster
and also, by default, includes a cloud native set of observability infrastructure via a set of "batteries removable"
[Fabrikate](https://github.com/Microsoft/fabrikate) stacks.

Cluster Creation
-   [Cluster Deployment](./cluster): Automated cluster creation
-   [Flux](https://github.com/weaveworks/flux): Secure GitOps Kubernetes Operator

Monitoring (via [fabrikate-prometheus-grafana](https://github.com/timfpark/fabrikate-prometheus-grafana))
-   [Prometheus](https://prometheus.io/) metrics monitoring and aggregation
-   [Grafana](https://grafana.com/) metrics visualization with Kubernetes monitoring dashboards preconfigured

Log Management (via [fabrikate-elasticsearch-fluentd-kibana](https://github.com/timfpark/fabrikate-elasticsearch-fluentd-kibana))
-   [Fluentd](https://www.fluentd.org/) collection and forwarding
-   [Elasticsearch](https://www.elastic.co/) aggregation
-   [Kibana](https://www.elastic.co/products/kibana) querying and visualization

## Getting Started

1. [Create and deploy a cluster](./cluster)

## Contributing

We do not claim to have all the answers and would greatly appreciate your ideas and pull requests.

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

For project related questions or comments, please contact [Tim Park](https://github.com/timfpark).
