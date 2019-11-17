param(
    [string]$KVReaderIdentityName = "sace-dev-kv-reader",
    [string]$AksResourceGroupName = "sace-dev-rg",
    [string]$AzureIdentityName = "sace-dev-kv-reader",
    [string]$AzureIdentityBindingName = "default-service-identity-binding",
    [string]$AzureBindingKubeNamespace = "default"
)

Write-Host "Ensure user-assigned identity is created"
[array]$msisFound = az identity list --resource-group $AksResourceGroupName --query "[?name=='$($KVReaderIdentityName)']" | ConvertFrom-Json
if ($null -eq $msisFound -or $msisFound.Count -eq 0) {
    throw "Unable to find kv reader identity '$($KVReaderIdentityName)' in '$AksResourceGroupName'"
}

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

Write-Host "Ensure azureidentity '$AzureIdentityName' is created"
[array]$existingAzureIdentities = kubectl get azureidentities.aadpodidentity.k8s.io -o json | jq ".[].name"
if ($null -eq $existingAzureIdentities -or $existingAzureIdentities.Count -eq 0) {
    throw "azureidentity '$AzureIdentityName' is not found"
}
$azureIdentityFound = $existingAzureIdentities | Where-Object { $_ -eq $AzureIdentityName }
if ($null -eq $azureIdentityFound) {
    throw "azureidentity '$AzureIdentityName' is not found"
}

Write-Host "Create azureidentitybinding '$AzureIdentityBindingName'"
$azureIdentityBindingYaml = @"
apiVersion: aadpodidentity.k8s.io/v1
kind: AzureIdentityBinding
metadata:
    name: $AzureIdentityBindingName
spec:
    AzureIdentity: $AzureIdentityName
    Selector: $KVReaderIdentityName
"@
$azureIdentityBindingYaml | kubectl apply --namespace $AzureBindingKubeNamespace -f -