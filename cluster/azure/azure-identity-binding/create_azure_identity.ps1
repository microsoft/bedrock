param(
    [string]$SubscriptionId,
    [string]$KVReaderIdentityName,
    [string]$AksResourceGroupName,
    [string]$AzureIdentityName,
    [string]$AzureBindingKubeNamespace = "default"
)

az account set -s $SubscriptionId

Write-Host "Ensure user-assigned identity '$KVReaderIdentityName' is created in '$AksResourceGroupName'"
[array]$msisFound = az identity list --resource-group $AksResourceGroupName --query "[?name=='$($KVReaderIdentityName)']" | ConvertFrom-Json
if ($null -eq $msisFound -or $msisFound.Count -eq 0) {
    throw "Unable to find kv reader identity '$($KVReaderIdentityName)' in '$AksResourceGroupName'"
}
$userAssignedIdentity = az identity show --resource-group $AksResourceGroupName --name $KVReaderIdentityName | ConvertFrom-Json

Write-Host "Ensure pod identity helm chart is deployed"
[array]$existingCrds = kubectl get crd -o json | jq -r ".items[].metadata.name" --raw-output
$foundPodIdentityCrd = $false
$totalRetries = 0
while (!$foundPodIdentityCrd -and $totalRetries -lt 10) {
    if ($null -ne $existingCrds -and $existingCrds.Count -gt 0) {
        Write-Host "aad pod identity deployment is done"
        $foundPodIdentityCrd = $existingCrds -contains "azureidentities.aadpodidentity.k8s.io"
    }
    $totalRetries++
    if (!$foundPodIdentityCrd) {
        Write-Host "attempt #$($totalRetries): waiting for aad deployment to be ready"
        Start-Sleep -Seconds 10
        [array]$existingCrds = kubectl get crd -o json | jq -r ".items[].metadata.name" --raw-output
    }
}
if (!$foundPodIdentityCrd) {
    throw "AAD pod identity is not deployed"
}

Write-Host "Create azureidentity '$AzureIdentityName'"
$azureIdentityYaml = @"
apiVersion: aadpodidentity.k8s.io/v1
kind: AzureIdentity
metadata:
    name: $AzureIdentityName
spec:
    type: 0
    ResourceID: $($userAssignedIdentity.id)
    ClientId: $($userAssignedIdentity.clientId)
"@
$azureIdentityYaml | kubectl apply --namespace $AzureBindingKubeNamespace -f -