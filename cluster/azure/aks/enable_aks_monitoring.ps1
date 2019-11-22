param(
    [string]$ResourceGroupName,
    [string]$ClusterName
)

try {
    az aks enable-addons --resource-group $ResourceGroupName --name $ClusterName --addons monitoring
}
catch {}