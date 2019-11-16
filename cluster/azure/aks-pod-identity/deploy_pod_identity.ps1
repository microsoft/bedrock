param(
    [Parameter(Mandatory=$true)]
    [string]$EnvName,
    [Parameter(Mandatory=$true)]
    [string]$ModuleFolder,
    [Parameter(Mandatory=$true)]
    [string]$PodIdentityVersion,
    [Parameter(Mandatory=$true)]
    [string]$PodIdentityNamespace
)

Write-Host "Applying configuration: version=$PodIdentityVersion, namespace=$PodIdentityNamespace"
$configFile = Join-Path (Join-Path $ModuleFolder "config") "common.yaml"
if (-not (Test-Path $configFile)) {
    throw "Unable to find config file: $configFile"
}
$configYaml = Get-Content $configFile -Raw
$configYaml = $configYaml.Replace("{{.Values.podIdentity.version}}", $PodIdentityVersion)
$configYaml = $configYaml.Replace("{{.Values.podIdentity.namespace}}", $PodIdentityNamespace)
Remove-Item $configFile -Force
[System.IO.File]::WriteAllText($configFile, $configYaml)

Write-Host "Generating pod-identity yaml for env $EnvName"
fab generate $EnvName
$generatedYamlFolder = Join-Path (Join-Path $ModuleFolder "generated") $EnvName
if (-not (Test-Path $generatedYamlFolder -PathType Container)) {
    throw "Failed to generate yaml files using fabrikate component"
}

Write-Host "kubectl apply -f $generatedYamlFolder"
kubectl apply -f $generatedYamlFolder