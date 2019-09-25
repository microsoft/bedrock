# Create an Azure DevOps Project from scratch using the Azure CLI DevOps extension

The [Azure DevOps Extension for Azure CLI](https://github.com/Azure/azure-devops-cli-extension) can create Pipelines, Boards and entire Projects via the familiar command line tool `az`.

The [script](./create-azdevops-project.sh) in this folder will create an Azure DevOps project in your organization together with a Pipeline linked to your `bedrock` fork. To use it:

- Fork https://github.com/microsoft/bedrock
- Edit the script adding your variables
- Install the Azure DevOps extension for Azure CLI:

```
az extension add --name azure-devops
```

- Run the script
- Link the pipeline to the variable groups

It will also populate two variable groups, one to store the Azure credentials (will be moved to an Azure Keyvault-linked variable group in the future) and one to store less sensitive information like the switches to enable/disable specific jobs.

#### Note

Due to this [issue](https://github.com/Azure/azure-devops-cli-extension/issues/639#issuecomment-513112820) the last step, linking the pipeline to the variable groups, has to be manual, unless we hardcode the variable group names into the pipeline YAML definition in this way:

```yaml
variables:
  - group: my-variable-group
  - group: my-other-variable-group
```
