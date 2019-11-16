param(
    [string]$KubeConfig,
    [string]$File
)

if (Test-Path $File) {
    Remove-Item $File -Force
}

[System.IO.File]::WriteAllText($File, $KubeConfig)