Param(
    [string] $appType,
    [ref] $compilationParams
)

$scriptPath = Join-Path $PSScriptRoot "../../../scripts/PreCompileApp.ps1" -Resolve
$projectFolder = Join-Path $PSScriptRoot "../../1st Party Apps (W1)"

if ($compilationParams.Value["appProjectFolder"] -match "Apps\\W1\\ReportLayouts") {
    Write-Host "Disabling AppSourceCop for Report Layouts"
    $compilationParams.Value["EnableAppSourceCop"] = $false
    $compilationParams.Value["EnablePerTenantExtensionCop"] = $false
}

. $scriptPath -parameters $compilationParams -currentProjectFolder $projectFolder -appType $appType