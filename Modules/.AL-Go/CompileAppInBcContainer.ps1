Param(
    [Hashtable] $parameters
)

$parameters["CurrentProjectFolder"] = "$env:GITHUB_WORKSPACE/Modules"

. "$env:GITHUB_WORKSPACE/Build/Scripts/CompileAppInBcContainer.ps1" -parameters $parameters