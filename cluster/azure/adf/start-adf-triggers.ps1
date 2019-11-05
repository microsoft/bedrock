param(
    [string]$AdfName,
    [string]$ResourceGroupName
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$foundAdf = $false
$existingAdfs = az rest --method GET --uri "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroupName/providers/Microsoft.DataFactory/factories?api-version=2018-06-01" | ConvertFrom-Json
if ($null -ne $existingAdfs -and $null -ne $existingAdfs.value) {
    if ($existingAdfs.value -is [array]) {
        $existingAdfs.value | ForEach-Object {
            $adf = $_
            if ($adf.name -eq $AdfName) {
                $foundAdf = $true
                Write-Host "found adf $($AdfName): $foundAdf"
            }
        }
    }
    elseif ($existingAdfs.value.name -eq $AdfName) {
        $foundAdf = $true
        Write-Host "found adf $($AdfName): $foundAdf"
    }
}

if ($foundAdf) {
    $triggers = az rest --method GET --uri "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroupName/providers/Microsoft.DataFactory/factories/$AdfName/triggers?api-version=2018-06-01" | ConvertFrom-Json

    if ($null -ne $triggers -and $null -ne $triggers.value) {
        if ($triggers.value -is [array]) {
            $triggers.value | ForEach-Object {
                $triggerName = $_.name
                Write-Host "Found trigger with name: $triggerName"
                Write-Host "Ebanling trigger with name: $triggerName"
                az rest --method POST --uri "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroupName/providers/Microsoft.DataFactory/factories/$AdfName/triggers/$triggerName/start?api-version=2018-06-01"
            }
        }
    }
}
