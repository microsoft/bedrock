$kubeconfig = [System.Environment]::GetEnvironmentVariable("kubeconfig", "process")
if ($null -eq $kubeconfig -or $kubeconfig -eq "") {
    throw "unable to find kubeconfig in environment varialbles"
}

$kubeconfigfile = [System.Environment]::GetEnvironmentVariable("kubeconfigfile", "process")
if ($null -eq $kubeconfigfile -or $kubeconfigfile -eq "") {
    throw "unable to find kubeconfigfile in environment varialbles"
}

if (Test-Path $kubeconfigfile) {
    Remove-Item $kubeconfigfile -Force
}

[System.IO.File]::WriteAllText($kubeconfigfile, $kubeconfig)