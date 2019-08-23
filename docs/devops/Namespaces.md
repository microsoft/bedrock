# Namespaces to Divide Cluster Resources
Namespaces divide a cluster into separate partitions that can be useful for development or release scenarios or large deployments that benefit from separation of resources.  During development, work can progress independently in a separate namespace before merging to the default or production namespace.  When used with a DevOps pipeline, namespaces support pull-request based development that leaves a record of commits and can be reverted to previous stages.

## Development Namespace
Using containers from previous examples, the following screenshot shows *azure-vote* and *mywebapp* services running in the *default* namespace, and another *mywebapp* container in the *dev* namespace.  This is common when an application already in production is being updated or modified.

![Namespaces](./images/namespaces1.png)

A previous document describes how to set up a [DevOps Pipeline to automate updates to Bedrock Deployment](README.md).  In this scenario the *dev* namespace can be specified in a manifest that includes tentative changes or a new application.  When review and testing are complete, a few lines of metadata in the manifest can be changed from the *dev* namespace to the *default* or production namespace.