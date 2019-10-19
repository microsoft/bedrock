param(
    [string]$AccountName,
    [string]$DbName,
    [string]$CollectionName,
    [string]$SpNames,
    [string]$VaultName
)

function GenerateCosmosDBAuthToken {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Verb,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceType,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceId,

        [Parameter(Mandatory = $true)]
        [string]
        $Date,

        [Parameter(Mandatory = $true)]
        [string]
        $Key,

        [Parameter(Mandatory = $false)]
        [string]
        $KeyType = 'master',

        [Parameter(Mandatory = $false)]
        [string]
        $TokenVersion = '1.0'
    )

    $payload = "$($verb.ToLowerInvariant())`n$($resourceType.ToLowerInvariant())`n$resourceId`n$($date.ToLowerInvariant())`n`n"

    $hmacSha256 = New-Object System.Security.Cryptography.HMACSHA256
    $hmacSha256.Key = [System.Convert]::FromBase64String($key)
    $encoding = [System.Text.Encoding]::UTF8
    $payloadHash = $hmacSha256.ComputeHash($encoding.GetBytes($payload))
    $signature = [System.Convert]::ToBase64String($payloadHash)
    return [System.Web.HttpUtility]::UrlEncode("type=$keyType&ver=$tokenVersion&sig=$signature")
}

function SubmitCosmosDbApiRequest {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Verb,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceId,

        [Parameter(Mandatory = $true)]
        [string]
        $ResourceType,

        [Parameter(Mandatory = $true)]
        [string]
        $Url,

        [Parameter(Mandatory = $true)]
        [string]
        $BodyJson,

        [Parameter(Mandatory = $true)]
        [string]
        $Key
    )

    $date = (Get-Date).ToUniversalTime().ToString('r')
    $authToken = GenerateCosmosDBAuthToken -Verb $Verb -ResourceType $ResourceType -ResourceId $ResourceId -Date $date -Key $Key

    # Add the headers
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", $authToken)
    $headers.Add("x-ms-version", '2015-08-06')
    $headers.Add("x-ms-date", $date)

    # Send the request and handle the result
    try {
        Invoke-RestMethod $Url `
            -Headers $headers `
            -Method $Verb `
            -ContentType 'application/json' `
            -Body $BodyJson
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 409) {
            return 'AlreadyExists'
        }
        else {
            throw
        }
    }
}

function DeployUserDefinedFunction {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $AccountName,

        [Parameter(Mandatory = $true)]
        [string]
        $AccountKey,

        [Parameter(Mandatory = $true)]
        [string]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [string]
        $CollectionName,

        [Parameter(Mandatory = $true)]
        [string]
        $UserDefinedFunctionName,

        [Parameter(Mandatory = $true)]
        [string]
        $SourceFilePath
    )

    # Assemble the UDF definition to send to Cosmos DB
    Write-Host 'Preparing UDF...'
    $sourceFileContents = Get-Content $SourceFilePath | Out-String
    $definition = @{
        body = $sourceFileContents
        id   = $UserDefinedFunctionName
    }
    $definitionJson = $definition | ConvertTo-Json

    CreateCosmosDBObject `
        -AccountName $AccountName `
        -AccountKey $AccountKey `
        -DatabaseName $DatabaseName `
        -CollectionName $CollectionName `
        -ObjectType UDF `
        -ObjectName $UserDefinedFunctionName `
        -Definition $definitionJson
}

function DeployStoredProcedure {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $AccountName,

        [Parameter(Mandatory = $true)]
        [string]
        $AccountKey,

        [Parameter(Mandatory = $true)]
        [string]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [string]
        $CollectionName,

        [Parameter(Mandatory = $true)]
        [string]
        $StoredProcedureName,

        [Parameter(Mandatory = $true)]
        [string]
        $SourceFilePath
    )

    # Assemble the stored procedure definition to send to Cosmos DB
    Write-Host 'Preparing stored procedure...'
    $sourceFileContents = Get-Content $SourceFilePath | Out-String
    $definition = @{
        body = $sourceFileContents
        id   = $StoredProcedureName
    }
    $definitionJson = $definition | ConvertTo-Json

    CreateCosmosDBObject `
        -AccountName $AccountName `
        -AccountKey $AccountKey `
        -DatabaseName $DatabaseName `
        -CollectionName $CollectionName `
        -ObjectType StoredProcedure `
        -ObjectName $StoredProcedureName `
        -Definition $definitionJson
}

function DeployTrigger {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $AccountName,

        [Parameter(Mandatory = $true)]
        [string]
        $AccountKey,

        [Parameter(Mandatory = $true)]
        [string]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [string]
        $CollectionName,

        [Parameter(Mandatory = $true)]
        [string]
        $TriggerName,

        [Parameter(Mandatory = $true)]
        [string]
        [ValidateSet('Pre', 'Post')]
        $TriggerType,

        [Parameter(Mandatory = $true)]
        [string]
        [ValidateSet('All', 'Create', 'Delete', 'Replace')]
        $TriggerOperation,

        [Parameter(Mandatory = $true)]
        [string]
        $SourceFilePath
    )

    # Assemble the trigger definition to send to Cosmos DB
    Write-Host 'Preparing trigger...'
    $sourceFileContents = Get-Content $SourceFilePath | Out-String
    $definition = @{
        body             = $sourceFileContents
        id               = $TriggerName
        triggerOperation = $TriggerOperation
        triggerType      = $TriggerType
    }
    $definitionJson = $definition | ConvertTo-Json

    CreateCosmosDBObject `
        -AccountName $AccountName `
        -AccountKey $AccountKey `
        -DatabaseName $DatabaseName `
        -CollectionName $CollectionName `
        -ObjectType Trigger `
        -ObjectName $TriggerName `
        -Definition $definitionJson
}
function ToBase64() {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$InputString
    )

    return [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($InputString))
}

function FromBase64() {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$InputString
    )

    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($InputString))
}

$AuthKey = $(az keyvault secret show --vault-name $VaultName --name "$($AccountName)-AuthKey" | ConvertFrom-Json).value
$ResourceType = 'sprocs'
$SpNameSecretArray = $SpNames.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries)

$SpNameSecretArray | ForEach-Object {
    $SpNameSecretPair = $_.Trim().Split("=", [System.StringSplitOptions]::RemoveEmptyEntries)
    $SpName = $SpNameSecretPair[0].Trim()
    if ($SpNameSecretPair.Count -gt 1) {
        $SpSecretName = $SpNameSecretPair[1]
    }
    else {
        $SpSecretName = $SpName
    }

    Write-Host "Installing $ResourceType '$SpName' to Cosmos DB collection '$CollectionName' in database '$DbName'..."

    $SpDefinition = $(az keyvault secret show --vault-name $VaultName --name $SpSecretName | ConvertFrom-Json).value | FromBase64

    $spJson = @{
        id = $SpName
        body = $SpDefinition
    } | ConvertTo-Json -Compress

    Write-Host $spJson

    $createResult = SubmitCosmosDbApiRequest `
        -Verb 'POST' `
        -ResourceId "dbs/$DbName/colls/$CollectionName" `
        -ResourceType $ResourceType `
        -Url "https://$AccountName.documents.azure.com/dbs/$DbName/colls/$CollectionName/$ResourceType" `
        -Key $AuthKey `
        -BodyJson $spJson

    # If that failed because the object already exists, update the object
    if ($createResult -eq 'AlreadyExists') {
        Write-Host "$ObjectType already exists. Updating..."
        SubmitCosmosDbApiRequest `
            -Verb 'PUT' `
            -ResourceId "dbs/$DbName/colls/$CollectionName/$ResourceType/$SpName" `
            -ResourceType $ResourceType `
            -Url "https://$AccountName.documents.azure.com/dbs/$DbName/colls/$CollectionName/$ResourceType/$SpName" `
            -Key $AuthKey `
            -BodyJson $spJson | Out-Null
    }
}
