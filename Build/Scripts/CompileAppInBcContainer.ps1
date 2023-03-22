Param(
    [Parameter(Mandatory=$true)]
    [string] $currentProjectFolder,
    [Hashtable] $parameters
)

Import-Module $PSScriptRoot\GuardingV2ExtensionsHelper.psm1
Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1
Import-Module $PSScriptRoot\Package\PackNuget.psm1

$appBuildMode = Get-BuildMode

# $app is a variable that determines whether the current app is a normal app (not test app, for instance)
if($app)
{
    # Setup compiler features to generate captions and LCGs
    if (!$parameters.ContainsKey("Features")) {
        $parameters["Features"] = @()
    }
    $parameters["Features"] += @("generateCaptions")

    # Setup compiler features to generate LCGs for the default build mode
    if($appBuildMode -eq 'Default') {
        $parameters["Features"] += @("lcgtranslationfile")
    }

    # Restore the baseline app and generate the AppSourceCop.json file
    if (($parameters.ContainsKey("EnableAppSourceCop") -and $parameters["EnableAppSourceCop"]) -or ($parameters.ContainsKey("EnablePerTenantExtensionCop") -and $parameters["EnablePerTenantExtensionCop"])) {
        Enable-BreakingChangesCheck -AppSymbolsFolder $parameters["appSymbolsFolder"] -AppProjectFolder $parameters["appProjectFolder"] -BuildMode $appBuildMode | Out-Null
    }
}

$appFile = Compile-AppInBcContainer @parameters

Write-Host "App Name: $($parameters['appName'])"
# Determine whether the current build is a CICD build
$CICDBuild = $env:GITHUB_WORKFLOW -and ($($env:GITHUB_WORKFLOW).Trim() -eq 'CI/CD')
$includeAppInPackage = Add-AppToPackage -ApplicationName $parameters["appName"]

if($CICDBuild -and $includeAppInPackage) {
    # Create the artifacts folder for the app to place in the package
    . $PSScriptRoot\Package\CreateAppPackageOutput.ps1 -AppProjectFolder $parameters["appProjectFolder"] -BuildMode $appBuildMode -AppFile $appFile -ALGoProjectFolder $currentProjectFolder -IsTestApp:$(!$app)
}

# Return the app file path 
$appFile