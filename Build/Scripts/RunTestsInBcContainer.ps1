Param(
    [Hashtable]$parameters
)

Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1

function Get-DisabledTestsFolder
{
    $baseFolder = Get-BaseFolder
    return "$baseFolder\Build\DisabledTests"
}

function Get-DisabledTests
(
    [string] $DisabledTestsFolder = (Get-DisabledTestsFolder)
)
{
    if(-not (Test-Path $DisabledTestsFolder))
    {
        return
    }

    $disabledCodeunits = Get-ChildItem -Filter "*.json" -Path $DisabledTestsFolder

    $disabledTests = @()
    foreach($disabledCodeunit in $disabledCodeunits)
    {
        $disabledTests += (Get-Content -Raw -Path $disabledCodeunit.FullName | ConvertFrom-Json)
    }

    return @($disabledTests)
}

$disabledTests = Get-DisabledTests

if ($disabledTests)
{
    $parameters["disabledTests"] = $disabledTests
}

$installedApps = Get-BcContainerAppInfo -containerName $parameters.ContainerName -tenantSpecificProperties -sort DependenciesLast
$appsToBeUnPublished = (Get-ConfigValue -ConfigType "BuildConfig" -Key "AppsNotToBePublished")
$installedApps | ForEach-Object {
    if ($_.Name -in $appsToBeUnPublished) {
        Write-Host "Unpublishing $($_.Name)"
        Unpublish-BcContainerApp -containerName $parameters.ContainerName -name $_.Name -unInstall -doNotSaveData -doNotSaveSchema -force
    }
}

Run-TestsInBcContainer @parameters