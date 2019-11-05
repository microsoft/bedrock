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
}

if ($foundAdf) {
    az rest --method DELETE --uri "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/$ResourceGroupName/providers/Microsoft.DataFactory/factories/$AdfName?api-version=2018-06-01"
}
