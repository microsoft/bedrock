param(
    [string]$ClusterName = "sacedev-dev1",
    [string]$ResourceGroupName = "sace-dev-dev1-rg",
    [string]$KubeConfigFile = "/Users/xiaodongli/work/sace/deploy/scripts/temp/dev/terraform/output/admin_kube_config",
    [switch]$IsAdmin
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
Install-Module powershell-yaml -AllowClobber -Confirm:$false -Force
Import-Module powershell-yaml -Force

if ($IsAdmin) {
    Write-Host "connect to aks as cluster admin"
    az aks get-credentials -g $ResourceGroupName -n $ClusterName --admin --overwrite-existing
    $userName = "clusterAdmin_$($ResourceGroupName)_$($ClusterName)"
    $contextName = "$($ClusterName)-admin"
}
else {
    Write-Host "connect to aks as cluster user"
    az aks get-credentials -g $ResourceGroupName -n $ClusterName --admin --overwrite-existing
    $userName = "clusterUser_$($ResourceGroupName)_$($ClusterName)"
    $contextName = $ClusterName
}

$baseKubeConfigFile = Join-Path (Join-Path $env:HOME ".kube") "config"
$configs = Get-Content $baseKubeConfigFile -Raw | ConvertFrom-Yaml -Ordered
$clusterConfig = $configs.clusters | Where-Object { $_.name -eq $ClusterName }
if ($null -eq $clusterConfig) {
    throw "invalid cluster name: $ClusterName"
}
$contextConfig = $configs.contexts | Where-Object { $_.name -eq $contextName }
if ($null -eq $contextConfig) {
    throw "invalid context name: $contextName"
}
$userConfig = $configs.users | Where-Object { $_.name -eq $userName }
if ($null -eq $userConfig) {
    throw "invalid user name: $userName"
}

$config = @{
    apiVersion = "v1"
    kind = "Config"
    preferences = @{}
    "current-context" = $contextName
    clusters = @($clusterConfig)
    contexts = @($contextConfig)
    users = @($userConfig)
}
$configYaml = $config | ConvertTo-Yaml

if (Test-Path $KubeConfigFile) {
    Remove-Item $KubeConfigFile
}

[System.IO.File]::WriteAllText($kubeconfigfile, $configYaml)