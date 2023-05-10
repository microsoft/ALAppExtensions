Param(
    [Hashtable]$parameters
)

$script = Join-Path $PSScriptRoot "../../Build/Scripts/NewBcContainer.ps1" -Resolve
. $script -parameters $parameters