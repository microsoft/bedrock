param(
    [string]$AdfName,
    [string]$ResourceGroupName
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$triggers = az rest --method GET --uri "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroupName/providers/Microsoft.DataFactory/factories/$AdfName/triggers?api-version=2018-06-01" | ConvertFrom-Json

$triggers.value | ForEach-Object {
    $triggerName = $_.name
    Write-Host "Found trigger with name: $triggerName"
    Write-Host "Disabling trigger with name: $triggerName"
    az rest --method POST --uri "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroupName/providers/Microsoft.DataFactory/factories/$AdfName/triggers/$triggerName/stop?api-version=2018-06-01"
}
