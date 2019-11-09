param(
    [string]$AppInsightsName,
    [string]$SubscriptionId,
    [string]$ResourceGroupName,
    [string]$Location
)

if ($null -ne $SubscriptionId -and $SubscriptionId -ne "") {
    az account set -s $SubscriptionId
}

$found = $false
try {
    $existingAppInsight = az monitor app-insights component show -g $ResourceGroupName -a $AppInsightsName | ConvertFrom-Json
    if ($null -ne $existingAppInsight) {
        $found = $true
    }
}
catch {
    $found = $false
}

if (!$found) {
    az monitor app-insights component create `
        -g $ResourceGroupName `
        -a $AppInsightsName `
        -l $Location `
        --application-type Web `
        --kind web
}