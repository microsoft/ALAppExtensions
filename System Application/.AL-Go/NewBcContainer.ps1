Param(
    [Hashtable]$parameters
)

$newContainerScript = Join-Path $PSScriptRoot "../../Build/Scripts/NewBcContainer.ps1"
. $newContainerScript -parameters $parameters