Param(
    [Hashtable]$parameters
)

$parameters.multitenant = $false
$parameters.RunSandboxAsOnPrem = $true
if ("$env:GITHUB_RUN_ID" -eq "") {
    $parameters.includeAL = $true
    $parameters.doNotExportObjectsToText = $true
    $parameters.shortcuts = "none"
}

$parameters.myscripts = @( @{ "SetupNavUsers.ps1" = "Write-Host 'Skipping user creation'" } )
$parameters.auth = 'Windows'

New-BcContainer @parameters

Invoke-ScriptInBcContainer -containerName $parameters.ContainerName -scriptblock { $progressPreference = 'SilentlyContinue' }