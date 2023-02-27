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

New-BcContainer @parameters

$installedApps = Get-BcContainerAppInfo -containerName $containerName -tenantSpecificProperties -sort DependenciesLast
$installedApps | ForEach-Object {
    $ApplicationName = $_.Name
    $removeData = $ApplicationName -ne "Base Application"
    $keepApplications = @("Base Application", "System Application", "Application", "Tests-TestLibraries", "System Application Test Library", "Library Variable Storage", "Any", "Library Assert", "Permissions Mock", "Library Variable Storage")
    if ($ApplicationName -notin $keepApplications) {
        Write-Host "Uninstalling $ApplicationName"
        Unpublish-BcContainerApp -containerName $containerName -name $ApplicationName -unInstall -doNotSaveData:$removeData -doNotSaveSchema:$removeData -force
    } else {
        Write-Host "Skipping uninstalling $ApplicationName"
    }
}

Invoke-ScriptInBcContainer -containerName $parameters.ContainerName -scriptblock { $progressPreference = 'SilentlyContinue' }