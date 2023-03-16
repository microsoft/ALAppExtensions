Param(
    [Hashtable] $parameters
)

. "$env:GITHUB_WORKSPACE/Build/Scripts/CompileAppInBcContainer.ps1" -parameters $parameters -currentProjectFolder (Join-Path $env:GITHUB_WORKSPACE "Test Stability Tools")