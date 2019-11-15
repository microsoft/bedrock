param(
    [string]$AccountName,
    [string]$SubscriptionId,
    [string]$ResourceGroupName,
    [string]$DbCollectionSettings
)

$json = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($DbCollectionSettings))
Write-Host "db setting as json: $json"

$dbSettingsArray = [array](ConvertFrom-Json $json -Depth 10)
if ($dbSettingsArray.Count -eq 0) {
    throw "invalid db settings"
}

if ($null -ne $SubscriptionId -and $SubscriptionId -ne "") {
    az account set -s $SubscriptionId | Out-Null
}

$dbSettingsArray | ForEach-Object {
    $dbSetting = $_
    $dbName = $dbSetting.name
    Write-Host "ensure cosmos db: $dbName"

    [array]$dbsFound = az cosmosdb database list --name $AccountName --resource-group $ResourceGroupName --query "[?id=='$dbName']" -o json | ConvertFrom-Json
    if ($null -eq $dbsFound -or $dbsFound.Count -eq 0) {
        Write-Host "creating cosmos db: $dbName"
        az cosmosdb database create --name $AccountName --resource-group $ResourceGroupName --db-name $dbName
    }
    else {
        Write-Host "cosmos db $dbName already created"
    }

    $collections = $dbSetting.collections
    Write-Host "Total of $($collections.Count) collections found for db: $dbName"

    $collections | ForEach-Object {
        $collection = $_
        Write-Host "provisioning collection, name=$($collection.name), partition=$($collection.partitionKey), throughput=$($collection.throughput)"
        [array]$collectionsFound = az cosmosdb collection list --name $AccountName --db-name $dbName --resource-group $ResourceGroupName --query "[?id=='$($collection.name)'].{id:id}" | ConvertFrom-Json
        if ($null -ne $collectionsFound -and $collectionsFound.Count -gt 0) {
            Write-Host "Collection $($collection.name) is already created"
        }
        else {
            if ($collection.partitionKey -eq "") {
                Write-Host "creating collection $($collection.name) without partition key"
                az cosmosdb collection create `
                    --name $AccountName `
                    --db-name $dbName `
                    --collection-name $collection.name `
                    --resource-group $ResourceGroupName `
                    --throughput $collection.throughput
            }
            else {
                Write-Host "creating collection $($collection.name) with partition key: $($collection.partitonKey)"
                az cosmosdb collection create `
                    --name $AccountName `
                    --db-name $dbName `
                    --collection-name $collection.name `
                    --resource-group $ResourceGroupName `
                    --partition-key-path $collection.partitionKey `
                    --throughput $collection.throughput
            }
        }
    }
}