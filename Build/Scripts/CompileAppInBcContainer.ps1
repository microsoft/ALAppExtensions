Param(
    [Parameter(Mandatory=$true)]
    [string] $currentProjectFolder,
    [Hashtable] $parameters
)

Import-Module $PSScriptRoot\EnlistmentHelperFunctions.psm1

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

    if($appBuildMode -eq 'Translated') {
        Import-Module $PSScriptRoot\AppTranslations.psm1
        Restore-TranslationsForApp -AppProjectFolder $parameters["appProjectFolder"]
    }

    # Restore the baseline app and generate the AppSourceCop.json file
    if (($parameters.ContainsKey("EnableAppSourceCop") -and $parameters["EnableAppSourceCop"]) -or ($parameters.ContainsKey("EnablePerTenantExtensionCop") -and $parameters["EnablePerTenantExtensionCop"])) {
        Import-Module $PSScriptRoot\GuardingV2ExtensionsHelper.psm1
        Enable-BreakingChangesCheck -AppSymbolsFolder $parameters["appSymbolsFolder"] -AppProjectFolder $parameters["appProjectFolder"] -BuildMode $appBuildMode | Out-Null
    }
}

$appFile = Compile-AppInBcContainer @parameters

# Return the app file path
$appFile