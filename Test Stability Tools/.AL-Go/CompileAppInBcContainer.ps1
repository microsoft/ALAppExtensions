Param(
    [Hashtable] $parameters
)
$scriptPath = Join-Path $PSScriptRoot "../../Build/Scripts/CompileAppInBcContainer.ps1" -Resolve
$projectFolder = Join-Path $PSScriptRoot "../../Test Stability Tools" -Resolve

. $scriptPath -parameters $parameters -currentProjectFolder $projectFolder