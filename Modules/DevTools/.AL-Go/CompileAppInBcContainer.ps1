Param(
    [Hashtable] $parameters
)

$parameters["CurrentProjectFolder"] = "$env:GITHUB_WORKSPACE/Modules/DevTools"

. "$env:GITHUB_WORKSPACE/Build/Scripts/CompileAppInBcContainer.ps1" -parameters $parameters