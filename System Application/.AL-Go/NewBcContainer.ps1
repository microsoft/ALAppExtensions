Param(
    [Hashtable]$parameters
)

$newContainerScript = Join-Path $PSScriptRoot "../../Build/Scripts/NewBcContainer.ps1" -Resolve
. $newContainerScript -parameters $parameters