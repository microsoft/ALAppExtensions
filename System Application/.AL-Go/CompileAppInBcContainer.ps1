Param(
    [Hashtable] $parameters
)

$script = Join-Path $PSScriptRoot "../../Build/Scripts/CompileAppInBcContainer.ps1" -Resolve
. $script -parameters $parameters -currentProjectFolder (Join-Path $env:GITHUB_WORKSPACE "System Application")