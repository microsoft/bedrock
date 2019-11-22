param(
    [string]$SubscriptionId,
    [string]$KVReaderIdentityName,
    [string]$AksResourceGroupName,
    [string]$AzureIdentityName,
    [string]$AzureIdentityBindingName,
    [string]$AzureBindingKubeNamespace
)

az account set -s $SubscriptionId

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
$totalRetries = 0
$azureIdentityFound = $false
while (!$azureIdentityFound -and $totalRetries -lt 10) {
    kubectl get azureidentities.aadpodidentity.k8s.io
    [array]$existingAzureIdentities = kubectl get azureidentities.aadpodidentity.k8s.io -o json | jq ".items[].metadata.name"
    if ($null -ne $existingAzureIdentities -or $existingAzureIdentities.Count -gt 0) {
        $existingAzureIdentities | ForEach-Object {
            [string]$currentIdentityName = $_
            $currentIdentityName = $currentIdentityName.Trim('"')
            if ($currentIdentityName -eq $AzureIdentityName) {
                $azureIdentityFound = $true
            }
            Write-Host "azure identity '$currentIdentityName' is deployed: $azureIdentityFound"
        }
    }

    $totalRetries++
    if (!$azureIdentityFound) {
        Write-Host "attempt #$($totalRetries): waiting for azure identity to be deployed"
        Start-Sleep -Seconds 10
    }
}
if (!$azureIdentityFound) {
    Write-Warning "azureidentity '$AzureIdentityName' is not found"
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