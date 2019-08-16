# Setup AAD Pod Identity

We will create a single pod identity and share it to all the services who need to access key vault (read-only)

## Steps

1. create a new identity (user-assigned) in MC resource group
2. grant identity `Reader` role to the following scopes:
    - MC resource group
    - Key vault
    - AKS cluster resource group
3. set keyvault policy and grant [secret,certificate]/[get,list] to identity

``` bash
az role assignment create --role Reader --assignee $identity.principalId --scope $scopeId
```
4. grant aks cluster spn `Managed Identity Operator` role to identity
``` bash
az role assignment create --role `Managed Identity Operator` --assignee $aksSpn.appId --scope $identity.id
```
5. for each service who is using pod identity, create `AzureIdentity`
``` yaml
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: {{.Values.service.name}}
spec:
  type: 0
  ResourceID: {{.Values.serviceIdentity.id}}
  ClientId: {{.Values.serviceIdentity.clientId}}
```
6. for each service who is using pod identity, create `AzureIdentityBinding`
``` yaml
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: "{{.Values.service.name}}-id-binding"
spec:
  AzureIdentity: "{{.Values.service.name}}"
  Selector: "{{.Values.service.label}}"
```
7. for each service who is using pod identity, add `aadpodidbinding` to labels
    - api/web
``` yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{.Values.service.name}}"
  labels:
    app: "{{.Values.service.name}}"
    aadpodidbinding: "{{.Values.service.name}}"
spec:
  replicas: {{.Values.service.replicas}}
  selector:
    matchLabels:
      app: "{{.Values.service.name}}"
  template:
    metadata:
      labels:
        app: "{{.Values.service.name}}"
        aadpodidbinding: "{{.Values.service.name}}"
```

    - job
``` yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: "{{.Values.service.name}}"
  labels:
    app: "{{.Values.service.name}}"
    aadpodidbinding: "{{.Values.service.name}}"
spec:
  concurrencyPolicy: "{{.Values.service.concurrencyPolicy}}"
  schedule: "{{.Values.service.schedule}}"
  jobTemplate:
    spec:
      template:
        metadata:
          name: "{{.Values.service.name}}"
          labels:
            app: "{{.Values.service.name}}"
            aadpodidbinding: "{{.Values.service.name}}"
        spec:
          restartPolicy: "{{.Values.service.restartPolicy}}"
```