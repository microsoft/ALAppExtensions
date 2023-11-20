Param(
    [string] $appType,
    [ref] $compilationParams
)

$scriptPath = Join-Path $PSScriptRoot "../../../scripts/PreCompileApp.ps1" -Resolve
$projectFolder = Join-Path $PSScriptRoot "../../1st Party Apps (W1)"

. $scriptPath -parameters $compilationParams -currentProjectFolder $projectFolder -appType $appType