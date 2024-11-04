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


$installedApps = Get-BcContainerAppInfo -containerName $parameters.containerName | Select-Object -ExpandProperty AppId
$extensionId = $parameters.extensionId
if ($extensionId -in $installedApps) {
    return Run-TestsInBcContainer @parameters
} else {
    Write-Host "Extension $extensionId is not installed in container $containerName. Skipping tests."
    return $true
}
